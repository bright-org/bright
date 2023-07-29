defmodule Bright.Repo.Migrations.AddCareerWantJobsToJobs do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :career_want_job_id, references(:career_want_jobs, on_delete: :nothing)
    end

    create index(:jobs, [:career_want_job_id])
  end
end
