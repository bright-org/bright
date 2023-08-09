defmodule Bright.Repo.Migrations.CreateCareerFieldSkillPanels do
  use Ecto.Migration

  def change do
    create table(:career_field_skill_panels) do
      add :career_field_id, references(:career_fields, on_delete: :nothing), null: false
      add :skill_panel_id, references(:skill_panels, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:career_field_skill_panels, [:career_field_id, :skill_panel_id])
  end
end
