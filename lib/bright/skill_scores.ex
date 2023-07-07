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
end
