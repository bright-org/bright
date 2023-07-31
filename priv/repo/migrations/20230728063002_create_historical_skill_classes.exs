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
  end
end
