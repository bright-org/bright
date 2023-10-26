defmodule Bright.Repo.Migrations.RemoveCareerFieldIdFromJobs do
  use Ecto.Migration

  def up do
    alter table(:jobs) do
      remove :career_field_id
    end

    drop_if_exists index(:jobs, [:career_field_id])
  end

  def down do
    alter table(:jobs) do
      add :career_field_id, references(:career_fields, on_delete: :nothing)
    end

    create_if_not_exists index(:jobs, [:career_field_id])
  end
end
