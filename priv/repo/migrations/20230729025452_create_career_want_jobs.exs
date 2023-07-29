defmodule Bright.Repo.Migrations.CreateCareerWantJobs do
  use Ecto.Migration

  def change do
    create table(:career_want_jobs) do
      add :career_want_id, references(:career_wants, on_delete: :nothing)
      add :job_id, references(:jobs, on_delete: :nothing)

      timestamps()
    end

    create index(:career_want_jobs, [:career_want_id])
    create index(:career_want_jobs, [:job_id])
  end
end
