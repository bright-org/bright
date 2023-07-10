defmodule Bright.SkillReferences do
  @moduledoc """
  The SkillReferences context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillReferences.SkillReference

  @doc """
  Returns the list of skill_references.

  ## Examples

      iex> list_skill_references()
      [%SkillReference{}, ...]

  """
  def list_skill_references do
    Repo.all(SkillReference)
  end

  @doc """
  Gets a single skill_reference.

  Raises `Ecto.NoResultsError` if the Skill reference does not exist.

  ## Examples

      iex> get_skill_reference!(123)
      %SkillReference{}

      iex> get_skill_reference!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_reference!(id), do: Repo.get!(SkillReference, id)

  @doc """
  Creates a skill_reference.

  ## Examples

      iex> create_skill_reference(%{field: value})
      {:ok, %SkillReference{}}

      iex> create_skill_reference(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_reference(attrs \\ %{}) do
    %SkillReference{}
    |> SkillReference.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill_reference.

  ## Examples

      iex> update_skill_reference(skill_reference, %{field: new_value})
      {:ok, %SkillReference{}}

      iex> update_skill_reference(skill_reference, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_reference(%SkillReference{} = skill_reference, attrs) do
    skill_reference
    |> SkillReference.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a skill_reference.

  ## Examples

      iex> delete_skill_reference(skill_reference)
      {:ok, %SkillReference{}}

      iex> delete_skill_reference(skill_reference)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_reference(%SkillReference{} = skill_reference) do
    Repo.delete(skill_reference)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_reference changes.

  ## Examples

      iex> change_skill_reference(skill_reference)
      %Ecto.Changeset{data: %SkillReference{}}

  """
  def change_skill_reference(%SkillReference{} = skill_reference, attrs \\ %{}) do
    SkillReference.changeset(skill_reference, attrs)
  end
end
