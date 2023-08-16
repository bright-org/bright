defmodule Bright.Repo.Migrations.CreateHistoricalSkillClassUnits do
  use Ecto.Migration

  def change do
    create table(:historical_skill_class_units) do
      add :historical_skill_class_id, references(:historical_skill_classes, on_delete: :nothing),
        null: false

      add :historical_skill_unit_id, references(:historical_skill_units, on_delete: :nothing),
        null: false

      add :trace_id, :uuid, null: false
      add :position, :integer, null: false

      timestamps()
    end
  end
end
