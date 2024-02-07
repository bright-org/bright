defmodule Bright.Repo.Migrations.CreateSkillScoreClassLogs do
  use Ecto.Migration

  def change do
    create table(:skill_class_score_logs) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :skill_class_id, references(:skill_classes, on_delete: :nothing), null: false
      add :date, :date, null: false
      add :percentage, :float, null: false

      timestamps()
    end

    create unique_index(:skill_class_score_logs, [:user_id, :skill_class_id, :date])
  end
end
