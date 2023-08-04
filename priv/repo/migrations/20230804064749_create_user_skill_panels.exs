defmodule Bright.Repo.Migrations.CreateUserSkillPanels do
  use Ecto.Migration

  def change do
    create table(:user_skill_panels) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :skill_panel_id, references(:skill_panels, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:user_skill_panels, [:user_id, :skill_panel_id])
  end
end
