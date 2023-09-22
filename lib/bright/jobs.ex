defmodule Bright.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Jobs.{Job, JobSkillPanel}

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
  end

  def list_jobs_with_career_fields do
    Repo.all(Job)
    |> Repo.preload(:career_fields)
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
    |> Repo.preload(:career_fields)
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
  Returns an `%Ecto.Changeset{}` for tracking job_skill_panel changes.

  ## Examples

      iex> change_job_skill_panel(job_skill_panel)
      %Ecto.Changeset{data: %JobSkillPanel{}}

  """
  def change_job_skill_panel(%JobSkillPanel{} = job_skill_panel, attrs \\ %{}) do
    JobSkillPanel.changeset(job_skill_panel, attrs)
  end

  @doc """
  Returns jobs group by career_field and job.rank

  ## Examples

      iex> list_jobs_group_by_career_field_and_rank()
      %{
        "engineer" =>
          %{
            entry: [%Job{}],
            basic: [%Job{}],
            advanced:[%Job{}],
            expert: [%Job{}]
          }
      }
  """
  def list_jobs_group_by_career_field_and_rank() do
    from(job in Job,
      join: cf in assoc(job, :career_fields),
      select: {cf.name_en, job}
    )
    |> Repo.all()
    |> Enum.group_by(fn {cf, _job} -> cf end, fn {_cf, job} -> job end)
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      sorted = Enum.sort_by(value, & &1.position)
      Map.put(acc, key, Enum.group_by(sorted, & &1.rank))
    end)
  end

  @doc """
  Returns Job Related SkillPanels group by CareerField

  ## Examples

      iex> list_skill_panels_group_by_career_field(id)
      %{%CareerField{} => [%SkillPanel{}, %SkillPanel{}]}
  """

  def list_skill_panels_group_by_career_field(id) do
    from(job in Job,
      where: job.id == ^id,
      join: sk in assoc(job, :skill_panels),
      join: cf in assoc(job, :career_fields),
      select: {cf, sk}
    )
    |> Repo.all()
    |> Enum.group_by(fn {cf, _sk} -> cf end, fn {_cf, sk} -> sk end)
  end
end
