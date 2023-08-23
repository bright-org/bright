defmodule Bright.HistoricalSkillUnitScore do
  @moduledoc """
  The HistoricalSkillUnitScore context.
  """
  import Ecto.Query, warn: false
  alias Bright.Repo
  alias Bright.HistoricalSkillScores.HistoricalSkillUnitScore

  @doc """
  Returns the list of historical_skill_unit_score.

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
    locked_date = {locked_date.year, locked_date.month, 1} |> Date.from_erl!()

    # TODO 現在は重複したデータ（該当月に２回以上実施）に未対応
    from(historical_skill_unit_score in HistoricalSkillUnitScore,
      join: historical_skill_unit in assoc(historical_skill_unit_score, :historical_skill_unit),
      join: historical_skill_classes in assoc(historical_skill_unit, :historical_skill_classes),
      join:
        historical_skill_class_units in assoc(
          historical_skill_unit,
          :historical_skill_class_units
        ),
      on: historical_skill_classes.class == ^class,
      on: historical_skill_classes.skill_panel_id == ^skill_panel_id,
      order_by: historical_skill_class_units.position,
      where:
        historical_skill_unit_score.user_id == ^user_id and
          historical_skill_unit_score.locked_date == ^locked_date,
      select: %{
        name: historical_skill_unit.name,
        percentage: historical_skill_unit_score.percentage,
        position: historical_skill_class_units.position
      }
    )
    |> Repo.all()
  end
end
