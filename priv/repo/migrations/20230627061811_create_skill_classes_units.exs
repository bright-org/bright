defmodule Bright.Repo.Migrations.CreateSkillClassesUnits do
  use Ecto.Migration

  def change do
    create table(:skill_classes_units, primary_key: false) do
      add :skill_class_id, references(:skill_classes, on_delete: :nothing), null: false
      add :skill_unit_id, references(:skill_units, on_delete: :nothing), null: false
    end

    create unique_index(:skill_classes_units, [:skill_class_id, :skill_unit_id])
  end
end
