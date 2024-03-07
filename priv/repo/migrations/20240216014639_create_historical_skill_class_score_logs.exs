defmodule Bright.Repo.Migrations.CreateHistoricalSkillClassScoreLogs do
  use Ecto.Migration

  def change do
    create table(:historical_skill_class_score_logs) do
      add :user_id, references(:users, on_delete: :nothing), null: false

      add :historical_skill_class_id, references(:historical_skill_classes, on_delete: :nothing),
        null: false

      add :date, :date, null: false
      add :percentage, :float, null: false

      timestamps()
    end

    create index(:historical_skill_class_score_logs, [:user_id])
    create index(:historical_skill_class_score_logs, [:historical_skill_class_id])
  end
end
