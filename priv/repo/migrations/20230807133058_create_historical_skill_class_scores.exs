defmodule Bright.Repo.Migrations.CreateHistoricalSkillClassScores do
  use Ecto.Migration

  def change do
    create table(:historical_skill_class_scores) do
      add :user_id, references(:users, on_delete: :nothing), null: false

      add :historical_skill_class_id, references(:historical_skill_classes, on_delete: :nothing),
        null: false

      add :locked_date, :date, null: false
      add :level, :string, null: false
      add :percentage, :float, null: false

      timestamps()
    end
  end
end
