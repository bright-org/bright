defmodule Bright.Repo.Migrations.CreateHistoricalSkillClasses do
  use Ecto.Migration

  def change do
    create table(:historical_skill_classes) do
      add :skill_panel_id, references(:skill_panels, on_delete: :nothing), null: false
      add :locked_date, :date, null: false
      add :trace_id, :uuid, null: false
      add :name, :string, null: false
      add :class, :integer, null: false

      timestamps()
    end

    create index(:historical_skill_classes, [:skill_panel_id])
    create index(:historical_skill_classes, [:locked_date])
    create index(:historical_skill_classes, [:trace_id])
    create index(:historical_skill_classes, [:class])
  end
end
