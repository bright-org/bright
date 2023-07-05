defmodule Bright.Repo.Migrations.CreateSkillClasses do
  use Ecto.Migration

  def change do
    create table(:skill_classes) do
      add :skill_panel_id, references(:skill_panels, on_delete: :nothing), null: false
      add :name, :string, null: false
      add :rank, :integer, null: false

      timestamps()
    end

    create unique_index(:skill_classes, [:skill_panel_id, :rank])
  end
end
