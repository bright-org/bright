defmodule Bright.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Jobs.CareerWant

  @doc """
  Returns the list of career_wants.

  ## Examples

      iex> list_career_wants()
      [%CareerWant{}, ...]

  """
  def list_career_wants do
    Repo.all(CareerWant)
  end

  @doc """
  Gets a single career_want.

  Raises `Ecto.NoResultsError` if the Career want does not exist.

  ## Examples

      iex> get_career_want!(123)
      %CareerWant{}

      iex> get_career_want!(456)
      ** (Ecto.NoResultsError)

  """
  def get_career_want!(id), do: Repo.get!(CareerWant, id)

  @doc """
  Creates a career_want.

  ## Examples

      iex> create_career_want(%{field: value})
      {:ok, %CareerWant{}}

      iex> create_career_want(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_career_want(attrs \\ %{}) do
    %CareerWant{}
    |> CareerWant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a career_want.

  ## Examples

      iex> update_career_want(career_want, %{field: new_value})
      {:ok, %CareerWant{}}

      iex> update_career_want(career_want, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_career_want(%CareerWant{} = career_want, attrs) do
    career_want
    |> CareerWant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a career_want.

  ## Examples

      iex> delete_career_want(career_want)
      {:ok, %CareerWant{}}

      iex> delete_career_want(career_want)
      {:error, %Ecto.Changeset{}}

  """
  def delete_career_want(%CareerWant{} = career_want) do
    Repo.delete(career_want)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking career_want changes.

  ## Examples

      iex> change_career_want(career_want)
      %Ecto.Changeset{data: %CareerWant{}}

  """
  def change_career_want(%CareerWant{} = career_want, attrs \\ %{}) do
    CareerWant.changeset(career_want, attrs)
  end

  alias Bright.Jobs.CareerField

  @doc """
  Returns the list of career_fields.

  ## Examples

      iex> list_career_fields()
      [%CareerField{}, ...]

  """
  def list_career_fields do
    Repo.all(CareerField)
  end

  @doc """
  Gets a single career_field.

  Raises `Ecto.NoResultsError` if the Career field does not exist.

  ## Examples

      iex> get_career_field!(123)
      %CareerField{}

      iex> get_career_field!(456)
      ** (Ecto.NoResultsError)

  """
  def get_career_field!(id), do: Repo.get!(CareerField, id)

  @doc """
  Creates a career_field.

  ## Examples

      iex> create_career_field(%{field: value})
      {:ok, %CareerField{}}

      iex> create_career_field(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_career_field(attrs \\ %{}) do
    %CareerField{}
    |> CareerField.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a career_field.

  ## Examples

      iex> update_career_field(career_field, %{field: new_value})
      {:ok, %CareerField{}}

      iex> update_career_field(career_field, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_career_field(%CareerField{} = career_field, attrs) do
    career_field
    |> CareerField.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a career_field.

  ## Examples

      iex> delete_career_field(career_field)
      {:ok, %CareerField{}}

      iex> delete_career_field(career_field)
      {:error, %Ecto.Changeset{}}

  """
  def delete_career_field(%CareerField{} = career_field) do
    Repo.delete(career_field)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking career_field changes.

  ## Examples

      iex> change_career_field(career_field)
      %Ecto.Changeset{data: %CareerField{}}

  """
  def change_career_field(%CareerField{} = career_field, attrs \\ %{}) do
    CareerField.changeset(career_field, attrs)
  end
end
