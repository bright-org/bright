defmodule Bright.Repo.Migrations.RecreateSkillClassScoreLogsIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:skill_class_score_logs, [:user_id, :skill_class_id, :date])
    create index(:skill_class_score_logs, [:user_id, :skill_class_id, :date])
  end
end
