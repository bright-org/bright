defmodule Bright.SkillScores do
  @moduledoc """
  The SkillScores context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillScores.SkillScore

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
  Creates a skill_score.

  ## Examples

      iex> create_skill_score(%{field: value})
      {:ok, %SkillScore{}}

      iex> create_skill_score(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_score(attrs \\ %{}) do
    %SkillScore{}
    |> SkillScore.changeset(attrs)
    |> Repo.insert()
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

  alias Bright.SkillScores.SkillScoreItem

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
  Creates a skill_score_item.

  ## Examples

      iex> create_skill_score_item(%{field: value})
      {:ok, %SkillScoreItem{}}

      iex> create_skill_score_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_score_item(attrs \\ %{}) do
    %SkillScoreItem{}
    |> SkillScoreItem.changeset(attrs)
    |> Repo.insert()
  end

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
end
