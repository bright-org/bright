defmodule Bright.SkillScores do
  @moduledoc """
  The SkillScores context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillUnits
  alias Bright.SkillScores.{SkillClassScore, SkillUnitScore, SkillScore}

  # レベルの判定値
  @normal_level 40
  @skilled_level 60

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

  @doc """
  Creates a skill_class_score with skill_scores

  スキルクラスに紐づくスキルユニットは別スキルクラスで入力済みの可能性があるため注意が必要
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
    |> Ecto.Multi.insert(:skill_class_score_init, %SkillClassScore{
      user_id: user.id,
      skill_class_id: skill_class.id
    })
    |> Ecto.Multi.insert_all(:skill_unit_scores, SkillUnitScore, fn _ ->
      skill_units
      |> Enum.filter(& &1.skill_unit_scores == [])
      |> Enum.map(& build_skill_unit_score_attrs(user, &1))
      |> Enum.filter(& &1)
    end)
    |> Ecto.Multi.insert_all(:skill_scores, SkillScore, fn _ ->
      skills
      |> Enum.filter(& &1.skill_scores == [])
      |> Enum.map(& build_skill_score_attrs(user, &1))
      |> Enum.filter(& &1)
    end)
    |> Ecto.Multi.run(:skill_class_score, fn _repo, %{skill_class_score_init: skill_class_score} ->
      update_skill_class_score_stats(skill_class_score)
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
  def update_skill_class_score_stats(skill_class_score) do
    skill_scores = list_skill_scores_from_skill_class_score(skill_class_score)

    size = Enum.count(skill_scores)
    num_high_scores = Enum.count(skill_scores, &(&1.score == :high))
    percentage = calc_percentage(num_high_scores, size)
    level = get_level(percentage)

    change_skill_class_score(skill_class_score, %{percentage: percentage, level: level})
    |> Repo.update()
  end

  @doc """
  Deletes a skill_class_score.

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
  Updates skill_scores.
  """
  def update_skill_scores(user, skill_class_score, skill_scores) do
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
    |> Ecto.Multi.run(:skill_class_score, fn _repo, _ ->
      update_skill_class_score_stats(skill_class_score)
    end)
    |> Ecto.Multi.run(:skill_unit_scores, fn _repo, _ ->
      # 更新対象のスキルが属するスキルユニットのみを対象としている
      skill_scores
      |> Repo.preload(skill: [skill_category: [:skill_unit]])
      |> Enum.map(& &1.skill.skill_category.skill_unit)
      |> Enum.uniq()
      |> then(&update_skill_unit_scores_stats(user, &1))
    end)
    |> Repo.transaction()
  end

  @doc """
  Deletes a skill_score.

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
end
