defmodule Bright.SkillUnits do
  @moduledoc """
  The SkillUnits context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillUnits.SkillUnit

  @doc """
  Returns the list of skill_units.

  ## Examples

      iex> list_skill_units()
      [%SkillUnit{}, ...]

  """
  def list_skill_units do
    Repo.all(SkillUnit)
  end

  @doc """
  Gets a single skill_unit.

  Raises `Ecto.NoResultsError` if the Skill unit does not exist.

  ## Examples

      iex> get_skill_unit!(123)
      %SkillUnit{}

      iex> get_skill_unit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_unit!(id), do: Repo.get!(SkillUnit, id)

  @doc """
  Creates a skill_unit.

  ## Examples

      iex> create_skill_unit(%{field: value})
      {:ok, %SkillUnit{}}

      iex> create_skill_unit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_unit(attrs \\ %{}) do
    %SkillUnit{}
    |> SkillUnit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill_unit.

  ## Examples

      iex> update_skill_unit(skill_unit, %{field: new_value})
      {:ok, %SkillUnit{}}

      iex> update_skill_unit(skill_unit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_unit(%SkillUnit{} = skill_unit, attrs) do
    skill_unit
    |> SkillUnit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a skill_unit.

  ## Examples

      iex> delete_skill_unit(skill_unit)
      {:ok, %SkillUnit{}}

      iex> delete_skill_unit(skill_unit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_unit(%SkillUnit{} = skill_unit) do
    Repo.delete(skill_unit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_unit changes.

  ## Examples

      iex> change_skill_unit(skill_unit)
      %Ecto.Changeset{data: %SkillUnit{}}

  """
  def change_skill_unit(%SkillUnit{} = skill_unit, attrs \\ %{}) do
    SkillUnit.changeset(skill_unit, attrs)
  end
end
