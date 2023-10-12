defmodule Bright.Repo.Migrations.AddHistoricalSkillScoresExamProgressAndFlugs do
  use Ecto.Migration

  def change do
    alter table(:historical_skill_scores) do
      add :exam_progress, :string
      add :reference_read, :boolean
      add :evidence_filled, :boolean
    end
  end
end
