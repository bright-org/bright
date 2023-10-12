defmodule Bright.CareerFields do
  @moduledoc """
  The CareerFields context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.CareerFields.{CareerField, CareerFieldJob}

  @doc """
  Returns the list of career_fields.

  ## Examples

      iex> list_career_fields()
      [%CareerField{}, ...]

  """
  def list_career_fields do
    CareerField
    |> order_by(:position)
    |> Repo.all()
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

  @doc """
  Creates a career_want_job.

  ## Examples

      iex> create_career_field_job(%{field: value})
      {:ok, %CareerFieldJob{}}

      iex> create_career_field_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_career_field_job(attrs \\ %{}) do
    %CareerFieldJob{}
    |> CareerFieldJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking career_field_job changes.

  ## Examples

      iex> change_career_field_job(career_field_job)
      %Ecto.Changeset{data: %CareerFieldJob{}}

  """
  def change_career_field_job(%CareerFieldJob{} = career_field_job, attrs \\ %{}) do
    CareerFieldJob.changeset(career_field_job, attrs)
  end
end
