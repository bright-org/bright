defmodule Bright.Repo.Migrations.CreateSkillClassUnits do
  use Ecto.Migration

  def change do
    create table(:skill_class_units) do
      add :skill_class_id, references(:skill_classes, on_delete: :nothing), null: false
      add :skill_unit_id, references(:skill_units, on_delete: :nothing), null: false
      add :position, :integer, null: false

      timestamps()
    end

    create unique_index(:skill_class_units, [:skill_class_id, :skill_unit_id, :position])
  end
end
