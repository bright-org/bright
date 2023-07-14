defmodule Bright.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Jobs.CareerFields

  @doc """
  Returns the list of career_fields.

  ## Examples

      iex> list_career_fields()
      [%CareerFields{}, ...]

  """
  def list_career_fields do
    Repo.all(CareerFields)
  end

  @doc """
  Gets a single career_fields.

  Raises `Ecto.NoResultsError` if the Career fields does not exist.

  ## Examples

      iex> get_career_fields!(123)
      %CareerFields{}

      iex> get_career_fields!(456)
      ** (Ecto.NoResultsError)

  """
  def get_career_fields!(id), do: Repo.get!(CareerFields, id)

  @doc """
  Creates a career_fields.

  ## Examples

      iex> create_career_fields(%{field: value})
      {:ok, %CareerFields{}}

      iex> create_career_fields(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_career_fields(attrs \\ %{}) do
    %CareerFields{}
    |> CareerFields.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a career_fields.

  ## Examples

      iex> update_career_fields(career_fields, %{field: new_value})
      {:ok, %CareerFields{}}

      iex> update_career_fields(career_fields, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_career_fields(%CareerFields{} = career_fields, attrs) do
    career_fields
    |> CareerFields.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a career_fields.

  ## Examples

      iex> delete_career_fields(career_fields)
      {:ok, %CareerFields{}}

      iex> delete_career_fields(career_fields)
      {:error, %Ecto.Changeset{}}

  """
  def delete_career_fields(%CareerFields{} = career_fields) do
    Repo.delete(career_fields)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking career_fields changes.

  ## Examples

      iex> change_career_fields(career_fields)
      %Ecto.Changeset{data: %CareerFields{}}

  """
  def change_career_fields(%CareerFields{} = career_fields, attrs \\ %{}) do
    CareerFields.changeset(career_fields, attrs)
  end
end
