defmodule Bright.HistoricalSkillScores do
  @moduledoc """
  The HistoricalSkillScores context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.HistoricalSkillUnits
  alias Bright.HistoricalSkillUnits.HistoricalSkillUnit
  alias Bright.HistoricalSkillPanels.HistoricalSkillClass
  alias Bright.HistoricalSkillScores.HistoricalSkillScore
  alias Bright.HistoricalSkillScores.HistoricalSkillClassScore
  alias Bright.HistoricalSkillScores.HistoricalSkillUnitScore

  @doc """
  Returns the list of historical_skill_scores.

  ## Examples

      iex> list_historical_skill_scores()
      [%HistoricalSkillScore{}, ...]

  """
  def list_historical_skill_scores(query \\ HistoricalSkillScore) do
    query
    |> Repo.all()
  end

  @doc """
  Returns the list of historical_skill_scores from historical_skill_class_score
  """
  def list_historical_skill_scores_from_historical_skill_class_score(nil), do: []

  def list_historical_skill_scores_from_historical_skill_class_score(%{
        historical_skill_class_id: historical_skill_class_id,
        user_id: user_id
      }) do
    HistoricalSkillUnits.list_historical_skills_on_historical_skill_class(%{
      id: historical_skill_class_id
    })
    |> Repo.preload(historical_skill_scores: HistoricalSkillScore.user_id_query(user_id))
    |> Enum.flat_map(& &1.historical_skill_scores)
  end

  @doc """
  Returns the list of historical_skill_scores from user and historical_skill_ids
  """
  def list_user_historical_skill_scores_from_historical_skill_ids(historical_skill_ids, user_id) do
    HistoricalSkillScore.user_id_query(user_id)
    |> HistoricalSkillScore.historical_skill_ids_query(historical_skill_ids)
    |> list_historical_skill_scores()
  end

  @doc """
  Returns the list of historical_skill_unit_score.

  `locked_date` is historical_skill_units.locked_date not historical_skill_unit_scores

  ## Examples

      iex> get_historical_skill_gem(user_id, skill_panel_id, class, locked_date)
      [
        %{
          name: "1-スキルユニット(class:1)",
          percentage: 22.22222222222222,
          position: 1
        }
      ]

  """
  def get_historical_skill_gem(user_id, skill_panel_id, class, locked_date) do
    from(historical_skill_unit in HistoricalSkillUnit,
      join:
        historical_skill_class_units in assoc(
          historical_skill_unit,
          :historical_skill_class_units
        ),
      join:
        historical_skill_classes in assoc(
          historical_skill_class_units,
          :historical_skill_class
        ),
      on: historical_skill_classes.class == ^class,
      on: historical_skill_classes.skill_panel_id == ^skill_panel_id,
      on: historical_skill_class_units.historical_skill_unit_id == historical_skill_unit.id,
      where: historical_skill_unit.locked_date == ^locked_date,
      order_by: historical_skill_class_units.position,
      preload: [
        historical_skill_class_units: historical_skill_class_units,
        historical_skill_unit_scores: ^HistoricalSkillUnitScore.user_id_query(user_id)
      ]
    )
    |> Repo.all()
    |> Enum.map(fn historical_skill_unit ->
      # historical_skill_unit_scoresは共有している数だけ取得しているがどれも同じ値のためfirstしている
      historical_skill_unit_score = List.first(historical_skill_unit.historical_skill_unit_scores)
      historical_skill_class_unit = List.first(historical_skill_unit.historical_skill_class_units)

      %{
        name: historical_skill_unit.name,
        percentage: Map.get(historical_skill_unit_score || %{}, :percentage, 0.0),
        position: Map.get(historical_skill_class_unit, :position),
        trace_id: historical_skill_unit.trace_id
      }
    end)
  end

  @doc """
  List historical_skill_class_scores.percentage with locked_date

  Given `from_date` and `to_date` is historical_skill_classes.locked_date not historical_skill_class_socres

  ## Examples

      iex> list_historical_skill_class_scores(locked_date, skill_panel_id, class, user_id, from_date, to_date)
      [
        {~D[2022-10-01], 15.555555555555555},
        {~D[2023-01-01], 25.0},
        ...
      ]
  """
  def list_historical_skill_class_score_percentages(
        skill_panel_id,
        class,
        user_id,
        from_date,
        to_date
      ) do
    from(
      historical_skill_class in HistoricalSkillClass,
      join:
        historical_skill_class_scores in assoc(
          historical_skill_class,
          :historical_skill_class_scores
        ),
      on: historical_skill_class_scores.user_id == ^user_id,
      where:
        historical_skill_class.skill_panel_id == ^skill_panel_id and
          historical_skill_class.class == ^class and
          historical_skill_class.locked_date >= ^from_date and
          historical_skill_class.locked_date <= ^to_date,
      select: {
        historical_skill_class_scores.locked_date,
        historical_skill_class_scores.percentage
      }
    )
    |> Repo.all()
    |> Enum.sort_by(&elem(&1, 0), {:asc, Date})
  end

  @doc """
  Returns historical_skill_class_score with given date
  """
  def get_historical_skill_class_score_by_user_skill_class(user, skill_class, date) do
    from(hscs in HistoricalSkillClassScore,
      join: hsc in assoc(hscs, :historical_skill_class),
      where: hscs.user_id == ^user.id,
      where: hscs.locked_date <= ^date,
      where: hsc.trace_id == ^skill_class.trace_id,
      order_by: {:desc, hscs.locked_date},
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Returns historical_skill_class_scores.percentage with given date
  """
  def get_historical_skill_class_score_percentage(user, skill_class, date) do
    get_historical_skill_class_score_by_user_skill_class(user, skill_class, date)
    |> Kernel.||(%{})
    |> Map.get(:percentage)
  end

  @doc """
  Returns historical_skill_unit_scores with given date
  """
  def list_historical_skill_unit_scores_by_user_skill_units(user, skill_units, date) do
    trace_ids = Enum.map(skill_units, & &1.trace_id)

    historical_score_by_trace_id =
      from(hscs in HistoricalSkillUnitScore,
        join: hsc in assoc(hscs, :historical_skill_unit),
        where: hscs.user_id == ^user.id,
        where: hscs.locked_date == ^date,
        where: hsc.trace_id in ^trace_ids,
        preload: [historical_skill_unit: hsc]
      )
      |> Repo.all()
      |> Map.new(&{&1.historical_skill_unit.trace_id, &1})

    # 指定のskill_unitsと同じ並びで返している
    # 意図的に一致するものがないときにnilを返しているので変更しないように注意
    skill_units
    |> Enum.map(&Map.get(historical_score_by_trace_id, &1.trace_id))
  end
end
