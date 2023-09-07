defmodule Bright.SkillScores do
  @moduledoc """
  The SkillScores context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillPanels
  alias Bright.SkillUnits
  alias Bright.SkillScores.{SkillClassScore, SkillUnitScore, SkillScore}
  alias Bright.HistoricalSkillPanels.HistoricalSkillClass

  # レベルの判定値
  @normal_level 40
  @skilled_level 60
  # 次のスキルクラスの開放値
  @next_skill_class_level 40

  @doc """
  指定のスキルクラスに関わるスコア集計をまとめて再計算する
  NOTE: スキルパネル更新処理といった構造変更があったときを想定した重い処理
  """
  def re_aggregate_scores(skill_classes) do
    skill_classes =
      Enum.map(skill_classes, fn skill_class ->
        Repo.preload(skill_class, [
          :skill_class_scores,
          skill_units: [
            :skill_unit_scores,
            skill_categories: [skills: [:skill_scores]]
          ]
        ])
      end)

    skill_units = skill_classes |> Enum.flat_map(& &1.skill_units) |> Enum.uniq()

    Ecto.Multi.new()
    |> Ecto.Multi.run(:all_skill_unit_scores, fn _repo, _data ->
      results = Enum.map(skill_units, &update_skill_unit_scores_associated_by/1)
      {:ok, results}
    end)
    |> Ecto.Multi.run(:all_skill_class_scores, fn _repo, _data ->
      results = Enum.map(skill_classes, &update_skill_class_scores_associated_by/1)
      {:ok, results}
    end)
    |> Repo.transaction()
  end

  defp update_skill_unit_scores_associated_by(skill_unit) do
    skills = skill_unit.skill_categories |> Enum.flat_map(& &1.skills)
    {skills_count, score_count_user_dict} = count_skill_scores_each_user(skills)

    skill_unit.skill_unit_scores
    |> Enum.reduce(Ecto.Multi.new(), fn skill_unit_score, multi ->
      user_id = skill_unit_score.user_id
      high_scores_count = get_in(score_count_user_dict, [user_id, :high]) || 0
      percentage = calc_percentage(high_scores_count, skills_count)
      changeset = SkillUnitScore.changeset(skill_unit_score, %{percentage: percentage})

      multi
      |> Ecto.Multi.update(:"update_skill_unit_score_#{user_id}", changeset)
    end)
    |> Repo.transaction()
  end

  defp update_skill_class_scores_associated_by(skill_class) do
    skills =
      skill_class.skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.flat_map(& &1.skills)

    {skills_count, score_count_user_dict} = count_skill_scores_each_user(skills)

    skill_class.skill_class_scores
    |> Enum.reduce(Ecto.Multi.new(), fn skill_class_score, multi ->
      user_id = skill_class_score.user_id
      high_scores_count = get_in(score_count_user_dict, [user_id, :high]) || 0
      percentage = calc_percentage(high_scores_count, skills_count)
      level = get_level(percentage)
      changeset = SkillUnitScore.changeset(skill_class_score, %{percentage: percentage})
      SkillClassScore.changeset(skill_class_score, %{percentage: percentage, level: level})

      multi
      |> Ecto.Multi.update(:"update_skill_class_score_#{user_id}", changeset)

      # # TODO: レベルアップと付随処理はUIをそろえる
      # |> Ecto.Multi.run(:"level_up_skill_class_score_#{uesr_id}", fn _repo, _ ->
      # end)
    end)
    |> Repo.transaction()
  end

  defp count_skill_scores_each_user(skills) do
    skills_count = Enum.count(skills)
    init_count = %{high: 0, middle: 0, low: 0}

    score_count_user_dict =
      Enum.reduce(skills, %{}, fn skill, acc ->
        Enum.reduce(skill.skill_scores, acc, fn skill_score, dict ->
          user_dict =
            dict
            |> Map.get(skill_score.user_id, init_count)
            |> Map.update(skill_score.score, 1, &(&1 + 1))

          Map.put(dict, skill_score.user_id, user_dict)
        end)
      end)

    {skills_count, score_count_user_dict}
  end

  @doc """
  Returns the list of skill_class_scores.

  ## Examples

      iex> list_skill_class_scores()
      [%SkillClassScore{}, ...]

  """
  def list_skill_class_scores do
    Repo.all(SkillClassScore)
  end

  @doc """
  Gets a single skill_class_score.

  Raises `Ecto.NoResultsError` if the Skill score does not exist.

  ## Examples

      iex> get_skill_class_score!(123)
      %SkillClassScore{}

      iex> get_skill_class_score!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_class_score!(id), do: Repo.get!(SkillClassScore, id)

  def get_skill_class_score_by(condition), do: Repo.get_by(SkillClassScore, condition)

  def get_skill_class_score_by!(condition), do: Repo.get_by!(SkillClassScore, condition)

  @doc """
  Creates a skill_class_score with skill_scores
  """
  def create_skill_class_score(user, skill_class) do
    skill_units =
      Ecto.assoc(skill_class, :skill_units)
      |> SkillUnits.list_skill_units()
      |> Repo.preload(skill_unit_scores: SkillUnitScore.user_query(user))

    skills =
      SkillUnits.list_skills_on_skill_class(skill_class)
      |> Repo.preload(skill_scores: SkillScore.user_query(user))

    Ecto.Multi.new()
    # スキルクラススコアの新規作成処理
    |> Ecto.Multi.insert(:skill_class_score_init, %SkillClassScore{
      user_id: user.id,
      skill_class_id: skill_class.id
    })
    # スキルクラスに含まれるスキルユニットの新規作成処理
    # ただし、別のスキルクラスで作成済みの可能性がある
    |> Ecto.Multi.insert_all(:skill_unit_scores, SkillUnitScore, fn _ ->
      skill_units
      |> Enum.filter(&(&1.skill_unit_scores == []))
      |> Enum.map(&build_skill_unit_score_attrs(user, &1))
    end)
    # スキルクラスに含まれるスキルスコアの新規作成処理
    # ただし、別のスキルクラスで作成済みの可能性がある
    |> Ecto.Multi.insert_all(:skill_scores, SkillScore, fn _ ->
      skills
      |> Enum.filter(&(&1.skill_scores == []))
      |> Enum.map(&build_skill_score_attrs(user, &1))
    end)
    # スキルクラススコアの更新処理
    # 既にスキルスコアが入っているケースのための更新
    |> Ecto.Multi.run(:skill_class_score, fn _repo, data ->
      skill_class_score = Map.get(data, :skill_class_score_init)
      update_skill_class_score_stats(user, skill_class, skill_class_score)
    end)
    |> Repo.transaction()
  end

  defp build_skill_unit_score_attrs(user, skill_unit) do
    %{
      id: Ecto.ULID.generate(),
      user_id: user.id,
      skill_unit_id: skill_unit.id,
      percentage: 0.0
    }
    |> Map.merge(current_time_stamp())
  end

  defp build_skill_score_attrs(user, skill) do
    %{
      id: Ecto.ULID.generate(),
      user_id: user.id,
      skill_id: skill.id,
      score: :low
    }
    |> Map.merge(current_time_stamp())
  end

  defp current_time_stamp do
    current_time = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    %{
      inserted_at: current_time,
      updated_at: current_time
    }
  end

  @doc """
  Updates a skill_class_score.
  TODO: 削除

  ## Examples

      iex> update_skill_class_score(skill_class_score, %{field: new_value})
      {:ok, %SkillClassScore{}}

      iex> update_skill_class_score(skill_class_score, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_class_score(%SkillClassScore{} = skill_class_score, attrs) do
    skill_class_score
    |> SkillClassScore.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a skill_class_score aggregation columns.
  """
  def update_skill_class_score_stats(user, skill_class, skill_class_score) do
    skill_scores = list_skill_scores_from_skill_class_score(skill_class_score)

    size = Enum.count(skill_scores)
    num_high_scores = Enum.count(skill_scores, &(&1.score == :high))
    percentage = calc_percentage(num_high_scores, size)
    level = get_level(percentage)

    changeset =
      change_skill_class_score(skill_class_score, %{percentage: percentage, level: level})

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update_skill_class_score, changeset)
    |> Ecto.Multi.run(:level_up_skill_class_score, fn _repo, _ ->
      if skill_up_to_next_skill_class?(skill_class_score.percentage, percentage) do
        result = create_next_skill_class_score(user, skill_class)
        {:ok, result}
      else
        # 次スキルクラスを開放しないケース
        {:ok, nil}
      end
    end)
    |> Repo.transaction()
  end

  defp create_next_skill_class_score(user, skill_class) do
    # 上位クラスのスキルクラススコアを作成
    next_skill_class =
      SkillPanels.get_skill_class_by(
        skill_panel_id: skill_class.skill_panel_id,
        class: skill_class.class + 1
      )

    next_skill_class_score =
      next_skill_class &&
        get_skill_class_score_by(
          user_id: user.id,
          skill_class_id: next_skill_class.id
        )

    # 未作成時のみ作成
    if next_skill_class && is_nil(next_skill_class_score) do
      {:ok, result} = create_skill_class_score(user, next_skill_class)
      result
    end
  end

  @doc """
  Updates a skill_class_scores aggregation columns.
  """
  def update_skill_class_scores_stats(user, skill_classes) do
    skill_classes
    |> Repo.preload(skill_class_scores: SkillClassScore.user_query(user))
    |> Enum.filter(&(&1.skill_class_scores != []))
    |> Enum.reduce(Ecto.Multi.new(), fn skill_class, multi ->
      skill_class_score = List.first(skill_class.skill_class_scores)

      multi
      |> Ecto.Multi.run(:"skill_class_score_#{skill_class_score.id}", fn _repo, _ ->
        update_skill_class_score_stats(user, skill_class, skill_class_score)
      end)
    end)
    |> Repo.transaction()
  end

  @doc """
  Deletes a skill_class_score.
  TODO: 削除

  ## Examples

      iex> delete_skill_class_score(skill_class_score)
      {:ok, %SkillClassScore{}}

      iex> delete_skill_class_score(skill_class_score)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_class_score(%SkillClassScore{} = skill_class_score) do
    Repo.delete(skill_class_score)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_class_score changes.

  ## Examples

      iex> change_skill_class_score(skill_class_score)
      %Ecto.Changeset{data: %SkillClassScore{}}

  """
  def change_skill_class_score(%SkillClassScore{} = skill_class_score, attrs \\ %{}) do
    SkillClassScore.changeset(skill_class_score, attrs)
  end

  @doc """
  Returns the level determined by percentage.
  """
  def get_level(percentage) do
    percentage
    |> case do
      v when v >= @skilled_level -> :skilled
      v when v >= @normal_level -> :normal
      _ -> :beginner
    end
  end

  defp skill_up_to_next_skill_class?(prev_percentage, percentage) do
    prev_percentage < @next_skill_class_level && percentage >= @next_skill_class_level
  end

  @doc """
  Returns the list of skill_scores.

  ## Examples

      iex> list_skill_scores()
      [%SkillScore{}, ...]

  """
  def list_skill_scores(query \\ SkillScore) do
    query
    |> Repo.all()
  end

  @doc """
  Returns the list of skill_scores from skill_class_score
  """
  def list_skill_scores_from_skill_class_score(%{skill_class_id: skill_class_id, user_id: user_id}) do
    SkillUnits.list_skills_on_skill_class(%{id: skill_class_id})
    |> Repo.preload(skill_scores: SkillScore.user_id_query(user_id))
    |> Enum.flat_map(& &1.skill_scores)
  end

  @doc """
  Returns the list of skill_scores from user and skill_ids
  """
  def list_user_skill_scores_from_skill_ids(user, skill_ids) do
    SkillScore.user_id_query(user.id)
    |> SkillScore.skill_ids_query(skill_ids)
    |> list_skill_scores()
  end

  @doc """
  Gets a single skill_score.

  Raises `Ecto.NoResultsError` if the Skill score item does not exist.

  ## Examples

      iex> get_skill_score!(123)
      %SkillScore{}

      iex> get_skill_score!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_score!(id), do: Repo.get!(SkillScore, id)

  @doc """
  Gets a single last updated skill_score
  """
  def get_latest_skill_score(user_id) do
    from(
      ss in SkillScore,
      where: ss.user_id == ^user_id,
      order_by: [desc: :updated_at],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Updates a skill_score.

  ## Examples

      iex> update_skill_score(skill_score, %{field: new_value})
      {:ok, %SkillScore{}}

      iex> update_skill_score(skill_score, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_score(%SkillScore{} = skill_score, attrs) do
    skill_score
    |> SkillScore.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Update a skill_score's evidence_filled
  """
  def update_skill_score_evidence_filled(user, skill) do
    skill_score = Repo.get_by!(SkillScore, user_id: user.id, skill_id: skill.id)

    if skill_score.evidence_filled do
      {:ok, skill_score}
    else
      update_skill_score(skill_score, %{evidence_filled: true})
    end
  end

  @doc """
  Updates skill_scores.
  """
  def update_skill_scores(user, skill_scores) do
    # 更新対象のスキルが属するスキルユニット/スキルクラスは集計更新対象
    skill_units =
      skill_scores
      |> Repo.preload(skill: [skill_category: [:skill_unit]])
      |> Enum.map(& &1.skill.skill_category.skill_unit)
      |> Enum.uniq()

    skill_classes =
      skill_units
      |> Repo.preload(:skill_classes)
      |> Enum.flat_map(& &1.skill_classes)
      |> Enum.uniq()

    skill_scores
    |> Enum.reduce(Ecto.Multi.new(), fn skill_score, multi ->
      # 値はすでに保存済みなのでforce_changeでchangesetを構成
      changeset =
        skill_score
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.force_change(:score, skill_score.score)

      multi
      |> Ecto.Multi.update(:"skill_score_#{skill_score.id}", changeset)
    end)
    |> Ecto.Multi.run(:skill_unit_scores, fn _repo, _ ->
      update_skill_unit_scores_stats(user, skill_units)
    end)
    |> Ecto.Multi.run(:skill_class_scores, fn _repo, _ ->
      update_skill_class_scores_stats(user, skill_classes)
    end)
    |> Repo.transaction()
  end

  @doc """
  Deletes a skill_score.
  TODO: 削除

  ## Examples

      iex> delete_skill_score(skill_score)
      {:ok, %SkillScore{}}

      iex> delete_skill_score(skill_score)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_score(%SkillScore{} = skill_score) do
    Repo.delete(skill_score)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_score changes.

  ## Examples

      iex> change_skill_score(skill_score)
      %Ecto.Changeset{data: %SkillScore{}}

  """
  def change_skill_score(%SkillScore{} = skill_score, attrs \\ %{}) do
    SkillScore.changeset(skill_score, attrs)
  end

  @doc """
  Gets a single skill_unit_score.

  Raises `Ecto.NoResultsError` if the Skill score does not exist.

  ## Examples

      iex> get_skill_unit_score!(123)
      %SkillClassScore{}

      iex> get_skill_unit_score!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_unit_score!(id), do: Repo.get!(SkillUnitScore, id)

  @doc """
  Updates a skill_unit_score aggregation columns.
  """
  def update_skill_unit_scores_stats(user, skill_units) do
    skill_units
    |> Repo.preload(
      skill_unit_scores: SkillUnitScore.user_query(user),
      skill_categories: [skills: [skill_scores: SkillScore.user_query(user)]]
    )
    |> Enum.reduce(Ecto.Multi.new(), fn skill_unit, multi ->
      skill_unit_score = List.first(skill_unit.skill_unit_scores)

      skill_scores =
        skill_unit.skill_categories
        |> Enum.flat_map(& &1.skills)
        |> Enum.map(&List.first(&1.skill_scores))
        |> Enum.filter(& &1)

      size = Enum.count(skill_scores)
      num_high_scores = Enum.count(skill_scores, &(&1.score == :high))
      percentage = calc_percentage(num_high_scores, size)
      changeset = SkillUnitScore.changeset(skill_unit_score, %{percentage: percentage})

      multi
      |> Ecto.Multi.update(:"skill_unit_score_#{skill_unit_score.id}", changeset)
    end)
    |> Repo.transaction()
  end

  defp calc_percentage(_value, 0), do: 0.0

  defp calc_percentage(value, size) do
    100 * (value / size)
  end

  @doc """
  Get Skill Gem

  ## Examples

      iex> get_skill_gem(user_id, skill_panel_id, class)
      [
        %{
          name: "name",
          percentage: 50,
          position: 1
        }
     ]
  """
  def get_skill_gem(user_id, skill_panel_id, class) do
    from(skill_unit_score in SkillUnitScore,
      join: skill_unit in assoc(skill_unit_score, :skill_unit),
      join: skill_classes in assoc(skill_unit, :skill_classes),
      join: skill_class_units in assoc(skill_classes, :skill_class_units),
      on: skill_classes.class == ^class,
      on: skill_classes.skill_panel_id == ^skill_panel_id,
      on: skill_class_units.skill_unit_id == skill_unit.id,
      where: skill_unit_score.user_id == ^user_id,
      order_by: skill_class_units.position,
      select: %{
        name: skill_unit.name,
        percentage: skill_unit_score.percentage,
        position: skill_class_units.position
      }
    )
    |> Repo.all()
  end

  @doc """
  Get Skill Gem

  ## Examples

      iex> get_class_score(user_id, skill_panel_id, class)
      %SkillClassScore{}
  """
  def get_class_score(user_id, skill_panel_id, class) do
    from(skill_class_score in SkillClassScore,
      join: skill_class in assoc(skill_class_score, :skill_class),
      on: skill_class.class == ^class and skill_class.skill_panel_id == ^skill_panel_id,
      where: skill_class_score.user_id == ^user_id
    )
    |> Repo.one()
  end

  @doc """
  Get historical_skill_class_scores

  ## Examples

      iex> get_historical_skill_class_scores(locked_date, skill_panel_id, class, user_id,from_date, to_date)
      [
        %{locked_date: ~D[2022-10-01], percentage: 15.555555555555555}
      ]
  """
  def get_historical_skill_class_scores(skill_panel_id, class, user_id, from_date, to_date) do
    from(
      historical_skill_class in HistoricalSkillClass,
      join:
        historical_skill_class_scores in assoc(
          historical_skill_class,
          :historical_skill_class_scores
        ),
      on:
        historical_skill_class_scores.user_id == ^user_id and
          historical_skill_class_scores.locked_date >= ^from_date and
          historical_skill_class_scores.locked_date <= ^to_date,
      where:
        historical_skill_class.skill_panel_id == ^skill_panel_id and
          historical_skill_class.class == ^class,
      select: {
        historical_skill_class_scores.locked_date,
        historical_skill_class_scores.percentage
      }
    )
    |> Repo.all()
  end
end
