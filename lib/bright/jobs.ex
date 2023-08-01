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
  def get_job!(id), do: Repo.get!(Job, id)

  @doc """
  Gets a single job with career fields.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job_with_career_fileds!(123)
      %Job{}

      iex> get_job_with_career_fileds!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job_with_career_fileds!(id) do
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

  def list_career_want_jobs_with_career_wants do
    query =
      from cw in CareerWant,
        join: cwj in CareerWantJob,
        on: cwj.career_want_id == cw.id,
        group_by: [cw.id],
        order_by: [cw.position],
        select: %{
          career_want_id: cw.id,
          career_want_name: cw.name
        }

    Repo.all(query)
  end

  @doc """
  やりたいことに関連づいているキャリアフィールドを取得し、やりたいこと単位でリストに
  [
    [
      %{
        background_color: "#165BC8",
        button_color: "#165BC8",
        career_field_name: "エンジニア"
      },
      %{
        background_color: "#FFFFDC",
        button_color: "#F1E3FF",
        career_field_name: "デザイナー"
      }
    ],
    [
      %{
        background_color: "#FFFFDC",
        button_color: "#F1E3FF",
        career_field_name: "デザイナー"
      }
    ],
    [
      %{
        background_color: "#F2FFE1",
        button_color: "#FFFFDC",
        career_field_name: "インフラ"
      }
    ]
  ]
  """
  def list_career_wants_jobs_with_career_fields do
    query =
      from cw in CareerWant,
        join: cwj in CareerWantJob,
        on: cwj.career_want_id == cw.id,
        join: j in Job,
        on: cwj.job_id == j.id,
        join: cf in CareerField,
        on: j.career_field_id == cf.id,
        group_by: [cw.id, cf.id],
        order_by: [asc: cw.position, asc: cf.position],
        select: %{
          career_want_id: cw.id,
          career_field_name: cf.name,
          background_color: cf.background_color,
          button_color: cf.button_color
        }

    Repo.all(query)
    |> Enum.group_by(fn x -> x.career_want_id end)
    |> Enum.map(fn {_key, value} ->
      Enum.map(value, fn x ->
        %{
          career_field_name: x.career_field_name,
          background_color: x.background_color,
          button_color: x.button_color
        }
      end)
    end)
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

  alias Bright.Jobs.JobSkillPanel

  @doc """
  Returns the list of job_skill_panels.

  ## Examples

      iex> list_job_skill_panels()
      [%JobSkillPanel{}, ...]

  """
  def list_job_skill_panels do
    Repo.all(JobSkillPanel)
  end

  def list_job_skill_panels_with_jobs_and_skill_panels do
    Repo.all(JobSkillPanel)
    |> Repo.preload(:job)
    |> Repo.preload(:skill_panel)
  end

  @doc """
  Gets a single job_skill_panel.

  Raises `Ecto.NoResultsError` if the Job skill panel does not exist.

  ## Examples

      iex> get_job_skill_panel!(123)
      %JobSkillPanel{}

      iex> get_job_skill_panel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job_skill_panel!(id), do: Repo.get!(JobSkillPanel, id)

  def get_job_skill_panel_with_jobs_and_skill_panels!(id) do
    Repo.get!(JobSkillPanel, id)
    |> Repo.preload(:job)
    |> Repo.preload(:skill_panel)
  end

  @doc """
  Creates a job_skill_panel.

  ## Examples

      iex> create_job_skill_panel(%{field: value})
      {:ok, %JobSkillPanel{}}

      iex> create_job_skill_panel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job_skill_panel(attrs \\ %{}) do
    %JobSkillPanel{}
    |> JobSkillPanel.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job_skill_panel.

  ## Examples

      iex> update_job_skill_panel(job_skill_panel, %{field: new_value})
      {:ok, %JobSkillPanel{}}

      iex> update_job_skill_panel(job_skill_panel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job_skill_panel(%JobSkillPanel{} = job_skill_panel, attrs) do
    job_skill_panel
    |> JobSkillPanel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job_skill_panel.

  ## Examples

      iex> delete_job_skill_panel(job_skill_panel)
      {:ok, %JobSkillPanel{}}

      iex> delete_job_skill_panel(job_skill_panel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job_skill_panel(%JobSkillPanel{} = job_skill_panel) do
    Repo.delete(job_skill_panel)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job_skill_panel changes.

  ## Examples

      iex> change_job_skill_panel(job_skill_panel)
      %Ecto.Changeset{data: %JobSkillPanel{}}

  """
  def change_job_skill_panel(%JobSkillPanel{} = job_skill_panel, attrs \\ %{}) do
    JobSkillPanel.changeset(job_skill_panel, attrs)
  end
end
