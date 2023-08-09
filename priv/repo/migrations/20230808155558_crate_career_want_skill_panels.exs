defmodule Bright.Repo.Migrations.CreateCareerWantSkillPanels do
  use Ecto.Migration

  def change do
    create table(:career_want_skill_panels) do
      add :career_want_id, references(:career_wants, on_delete: :nothing)
      add :skill_panel_id, references(:skill_panels, on_delete: :nothing)

      timestamps()
    end

    create index(:career_want_skill_panels, [:career_want_id])
    create index(:career_want_skill_panels, [:skill_panel_id])
  end
end
