defmodule Bright.Repo.Migrations.AddIsStarToUserSkillPanels do
  use Ecto.Migration

  def change do
    alter table(:user_skill_panels) do
      add :is_star, :boolean, null: false, default: false
    end
  end
end
