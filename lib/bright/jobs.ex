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

  alias Bright.Jobs.Job

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
    |> Repo.preload(:career_field)
  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id) do
    Repo.get!(Job, id)
    |> Repo.preload(:career_field)
  end

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{data: %Job{}}

  """
  def change_job(%Job{} = job, attrs \\ %{}) do
    Job.changeset(job, attrs)
  end

  alias Bright.Jobs.CareerWantJob

  @doc """
  Returns the list of career_want_jobs.

  ## Examples

      iex> list_career_want_jobs()
      [%CareerWantJob{}, ...]

  """
  def list_career_want_jobs do
    Repo.all(CareerWantJob)
    |> Repo.preload(:career_want)
    |> Repo.preload(:job)
  end

  @doc """
  Gets a single career_want_job.

  Raises `Ecto.NoResultsError` if the Career want job does not exist.

  ## Examples

      iex> get_career_want_job!(123)
      %CareerWantJob{}

      iex> get_career_want_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_career_want_job!(id) do
    Repo.get!(CareerWantJob, id)
    |> Repo.preload(:career_want)
    |> Repo.preload(:job)
  end

  @doc """
  Creates a career_want_job.

  ## Examples

      iex> create_career_want_job(%{field: value})
      {:ok, %CareerWantJob{}}

      iex> create_career_want_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_career_want_job(attrs \\ %{}) do
    %CareerWantJob{}
    |> CareerWantJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a career_want_job.

  ## Examples

      iex> update_career_want_job(career_want_job, %{field: new_value})
      {:ok, %CareerWantJob{}}

      iex> update_career_want_job(career_want_job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_career_want_job(%CareerWantJob{} = career_want_job, attrs) do
    career_want_job
    |> CareerWantJob.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a career_want_job.

  ## Examples

      iex> delete_career_want_job(career_want_job)
      {:ok, %CareerWantJob{}}

      iex> delete_career_want_job(career_want_job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_career_want_job(%CareerWantJob{} = career_want_job) do
    Repo.delete(career_want_job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking career_want_job changes.

  ## Examples

      iex> change_career_want_job(career_want_job)
      %Ecto.Changeset{data: %CareerWantJob{}}

  """
  def change_career_want_job(%CareerWantJob{} = career_want_job, attrs \\ %{}) do
    CareerWantJob.changeset(career_want_job, attrs)
  end
end
