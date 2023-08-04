defmodule Bright.SkillScores do
  @moduledoc """
  The SkillScores context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillUnits
  alias Bright.SkillScores.{SkillScore, SkillScoreItem}

  # レベルの判定値
  @normal_level 40
  @skilled_level 60

  @doc """
  Returns the list of skill_scores.

  ## Examples

      iex> list_skill_scores()
      [%SkillScore{}, ...]

  """
  def list_skill_scores do
    Repo.all(SkillScore)
  end

  @doc """
  Gets a single skill_score.

  Raises `Ecto.NoResultsError` if the Skill score does not exist.

  ## Examples

      iex> get_skill_score!(123)
      %SkillScore{}

      iex> get_skill_score!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_score!(id), do: Repo.get!(SkillScore, id)

  @doc """
  Creates a skill_score with skill_score_items
  """
  def create_skill_score(user, skill_class) do
    skills = SkillUnits.list_skills_on_skill_class(skill_class)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:skill_score, %SkillScore{
      user_id: user.id,
      skill_class_id: skill_class.id
    })
    |> Ecto.Multi.insert_all(:skill_score_items, SkillScoreItem, fn %{skill_score: skill_score} ->
      skills
      |> Enum.map(fn skill ->
        current_time = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

        %{
          id: Ecto.ULID.generate(),
          skill_score_id: skill_score.id,
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
  Updates a skill_score aggregation columns.
  """
  def update_skill_score_stats(skill_score) do
    skill_score_items =
      Ecto.assoc(skill_score, :skill_score_items)
      |> list_skill_score_items()

    size = Enum.count(skill_score_items)
    num_skilled_items = Enum.count(skill_score_items, &(&1.score == :high))
    percentage = if size > 0, do: 100 * (num_skilled_items / size), else: 0.0
    level = get_level(percentage)

    change_skill_score(skill_score, %{percentage: percentage, level: level})
    |> Repo.update()
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
  Returns the list of skill_score_items.

  ## Examples

      iex> list_skill_score_items()
      [%SkillScoreItem{}, ...]

  """
  def list_skill_score_items(query \\ SkillScoreItem) do
    query
    |> Repo.all()
  end

  @doc """
  Gets a single skill_score_item.

  Raises `Ecto.NoResultsError` if the Skill score item does not exist.

  ## Examples

      iex> get_skill_score_item!(123)
      %SkillScoreItem{}

      iex> get_skill_score_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_score_item!(id), do: Repo.get!(SkillScoreItem, id)

  @doc """
  Updates a skill_score_item.

  ## Examples

      iex> update_skill_score_item(skill_score_item, %{field: new_value})
      {:ok, %SkillScoreItem{}}

      iex> update_skill_score_item(skill_score_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_score_item(%SkillScoreItem{} = skill_score_item, attrs) do
    skill_score_item
    |> SkillScoreItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates skill_score_items.
  """
  def update_skill_score_items(skill_score, skill_score_items) do
    skill_score_items
    |> Enum.reduce(Ecto.Multi.new(), fn skill_score_item, multi ->
      # 値はすでに保存済みなのでforce_changeでchangesetを構成
      changeset =
        skill_score_item
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.force_change(:score, skill_score_item.score)

      multi
      |> Ecto.Multi.update(:"skill_score_item_#{skill_score_item.id}", changeset)
    end)
    |> Ecto.Multi.run(:skill_score, fn _repo, _ ->
      update_skill_score_stats(skill_score)
    end)
    |> Repo.transaction()
  end

  @doc """
  Deletes a skill_score_item.

  ## Examples

      iex> delete_skill_score_item(skill_score_item)
      {:ok, %SkillScoreItem{}}

      iex> delete_skill_score_item(skill_score_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_score_item(%SkillScoreItem{} = skill_score_item) do
    Repo.delete(skill_score_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_score_item changes.

  ## Examples

      iex> change_skill_score_item(skill_score_item)
      %Ecto.Changeset{data: %SkillScoreItem{}}

  """
  def change_skill_score_item(%SkillScoreItem{} = skill_score_item, attrs \\ %{}) do
    SkillScoreItem.changeset(skill_score_item, attrs)
  end

  def get_level_by_class_in_skills_panel() do
    from(skill_score in SkillScore,
      join: skill_class in assoc(skill_score, :skill_class),
      join: skill_panel in assoc(skill_class, :skill_panel),
      group_by: skill_panel.name,
      select: %{
        name: skill_panel.name,
        class1:
          fragment(
            "MAX(CASE ? WHEN 1 THEN ? ELSE null END)",
            skill_class.class,
            skill_score.level
          ),
        class2:
          fragment(
            "MAX(CASE ? WHEN 2 THEN ? ELSE null END)",
            skill_class.class,
            skill_score.level
          ),
        class3:
          fragment(
            "MAX(CASE ? WHEN 3 THEN ? ELSE null END)",
            skill_class.class,
            skill_score.level
          )
      }
    )
    |> Repo.all()
  end
end
