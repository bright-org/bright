defmodule Bright.Repo.Migrations.CreateCareerFieldJobs do
  use Ecto.Migration

  def change do
    create table(:career_field_jobs) do
      add :career_field_id, references(:career_fields, on_delete: :nothing), null: false
      add :job_id, references(:jobs, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:career_field_jobs, [:career_field_id, :job_id])
  end
end
