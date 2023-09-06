defmodule Bright.TalentedPersons do
  @moduledoc """
  The TalentedPersons context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.TalentedPersons.TalentedPerson

  @doc """
  Returns the list of talented_persons.

  ## Examples

      iex> list_talented_persons()
      [%TalentedPerson{}, ...]

  """
  def list_talented_persons do
    Repo.all(TalentedPerson)
  end

  @doc """
  Gets a single talented_person.

  Raises `Ecto.NoResultsError` if the Talented person does not exist.

  ## Examples

      iex> get_talented_person!(123)
      %TalentedPerson{}

      iex> get_talented_person!(456)
      ** (Ecto.NoResultsError)

  """
  def get_talented_person!(id), do: Repo.get!(TalentedPerson, id)

  @doc """
  Creates a talented_person.

  ## Examples

      iex> create_talented_person(%{field: value})
      {:ok, %TalentedPerson{}}

      iex> create_talented_person(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_talented_person(attrs \\ %{}) do
    %TalentedPerson{}
    |> TalentedPerson.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a talented_person.

  ## Examples

      iex> update_talented_person(talented_person, %{field: new_value})
      {:ok, %TalentedPerson{}}

      iex> update_talented_person(talented_person, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_talented_person(%TalentedPerson{} = talented_person, attrs) do
    talented_person
    |> TalentedPerson.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a talented_person.

  ## Examples

      iex> delete_talented_person(talented_person)
      {:ok, %TalentedPerson{}}

      iex> delete_talented_person(talented_person)
      {:error, %Ecto.Changeset{}}

  """
  def delete_talented_person(%TalentedPerson{} = talented_person) do
    Repo.delete(talented_person)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking talented_person changes.

  ## Examples

      iex> change_talented_person(talented_person)
      %Ecto.Changeset{data: %TalentedPerson{}}

  """
  def change_talented_person(%TalentedPerson{} = talented_person, attrs \\ %{}) do
    TalentedPerson.changeset(talented_person, attrs)
  end
end
