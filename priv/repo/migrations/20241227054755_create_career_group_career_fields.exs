defmodule Bright.Repo.Migrations.CreateCareerGroupCareerFields do
  use Ecto.Migration

  def change do
    create table(:career_group_career_fields) do
      add :career_group_id, references(:career_groups, on_delete: :nothing)
      add :career_field_id, references(:career_fields, on_delete: :nothing)

      timestamps()
    end

    create index(:career_group_career_fields, [:career_group_id])
    create index(:career_group_career_fields, [:career_field_id])
  end
end
