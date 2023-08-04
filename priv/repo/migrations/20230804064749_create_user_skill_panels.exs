defmodule Bright.Repo.Migrations.CreateUserSkillPanels do
  use Ecto.Migration

  def change do
    create table(:user_skill_panels) do
      add :user_id, :uuid
      add :skill_panel_id, :uuid

      timestamps()
    end
  end
end
