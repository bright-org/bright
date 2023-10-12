defmodule Bright.Repo.Migrations.AddSkillScoresExamProgressAndFlugs do
  use Ecto.Migration

  def change do
    alter table(:skill_scores) do
      add :exam_progress, :string
      add :reference_read, :boolean
      add :evidence_filled, :boolean
    end
  end
end
