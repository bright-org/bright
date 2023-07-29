defmodule Bright.Repo.Migrations.CreateDraftSkillClassUnits do
  use Ecto.Migration

  def change do
    create table(:draft_skill_class_units) do
      add :draft_skill_class_id, references(:draft_skill_classes, on_delete: :nothing),
        null: false

      add :draft_skill_unit_id, references(:draft_skill_units, on_delete: :nothing), null: false
      add :trace_id, :uuid, null: false
      add :position, :integer, null: false

      timestamps()
    end

    create unique_index(:draft_skill_class_units, [
             :draft_skill_class_id,
             :draft_skill_unit_id,
             :position
           ])

    create unique_index(:draft_skill_class_units, [:trace_id])
  end
end
