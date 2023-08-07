defmodule Bright.SkillScores do
  @moduledoc """
  The SkillScores context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillUnits
  alias Bright.SkillScores.{SkillClassScore, SkillScore}

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
  """
  def create_skill_class_score(user, skill_class) do
    skills = SkillUnits.list_skills_on_skill_class(skill_class)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:skill_class_score, %SkillClassScore{
      user_id: user.id,
      skill_class_id: skill_class.id
    })
    |> Ecto.Multi.insert_all(:skill_scores, SkillScore, fn _ ->
      # TODO 重複可能性がある。
      skills
      |> Enum.map(fn skill ->
        current_time = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

        %{
          id: Ecto.ULID.generate(),
          user_id: user.id,
          skill_id: skill.id,
          score: :low,
          inserted_at: current_time,
          updated_at: current_time
        }
      end)
    end)
    |> Repo.transaction()
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
    num_skilled_items = Enum.count(skill_scores, &(&1.score == :high))
    percentage = if size > 0, do: 100 * (num_skilled_items / size), else: 0.0
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
  def update_skill_scores(skill_class_score, skill_scores) do
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
end
