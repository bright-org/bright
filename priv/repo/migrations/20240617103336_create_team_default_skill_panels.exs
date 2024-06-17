defmodule Bright.Repo.Migrations.CreateTeamDefaultSkillPanels do
  use Ecto.Migration

  def change do
    create table(:team_default_skill_panels) do
      add :team_id, references(:teams, on_delete: :nothing), null: false
      add :skill_panel_id, references(:skill_panels, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:team_default_skill_panels, [:team_id, :skill_panel_id])
  end
end
