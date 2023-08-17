defmodule Bright.Repo.Migrations.AddSkillPanelIdToUserOnboarding do
  use Ecto.Migration

  def change do
    alter table(:user_onboardings) do
      add :skill_panel_id, references(:skill_panels, on_delete: :nothing)
    end
  end
end
