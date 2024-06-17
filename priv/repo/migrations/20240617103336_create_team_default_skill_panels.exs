defmodule Bright.Repo.Migrations.CreateTeamDefaultSkillPanels do
  use Ecto.Migration

  def change do
    create table(:team_default_skill_panels) do
      add :team_id, :uuid
      add :skill_panel_id, :uuid

      timestamps()
    end
  end
end
