defmodule Bright.Repo.Migrations.CreateDraftSkillClasses do
  use Ecto.Migration

  def change do
    create table(:draft_skill_classes) do
      add :skill_panel_id, references(:skill_panels, on_delete: :nothing), null: false
      add :trace_id, :uuid, null: false
      add :name, :string, null: false
      add :class, :integer, null: false

      timestamps()
    end

    create index(:draft_skill_classes, [:skill_panel_id])
  end
end
