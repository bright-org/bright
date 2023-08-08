defmodule Bright.Repo.Migrations.AddCareerFieldIdToSkillPanels do
  use Ecto.Migration

  def change do
    alter table(:skill_panels) do
      add :career_field_id, references(:career_fields, on_delete: :nothing)
    end
  end
end
