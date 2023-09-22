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
    from(j in Job, order_by: j.position)
    |> Repo.all()
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

  def list_skill_panels_by_career_want_id do
    # TODO: DBからデータ取得
    %{
      "01H75APD4QK5WDQMQCVY1XM9XT" => [
        %{name: "Webアプリ開発 Elixir", skill_panel_id: "01H77AMPH7X5ZZPN3FRVNACTYH"},
        %{name: "コミュニケーションスキル", skill_panel_id: "01H77ANY2SXDRD0PX8VP66SNPZ"}
      ],
      "01H75APD6YQPVR7Z6M3NA66WCB" => [
        %{name: "Webデザイン", skill_panel_id: "01H77ANY2SXDRD0PX8VP66SNPZ"}
      ]
    }
  end

  def list_career_fields_by_career_wants do
    # TODO: DBからデータ取得
    %{
      "01H75APD4QK5WDQMQCVY1XM9XT" => %{name_en: "engineer", name_ja: "エンジニア"},
      "01H75APD6YQPVR7Z6M3NA66WCB" => %{name_en: "designer", name_ja: "デザイナー"}
    }
  end
end
