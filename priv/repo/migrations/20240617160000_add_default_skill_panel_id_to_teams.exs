defmodule Bright.Repo.Migrations.AddDefaultSkillPanelIdToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :default_skill_panel_id, :uuid, default: nil
    end
  end
end
