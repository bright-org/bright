defmodule Bright.Repo.Migrations.CreateSkillScores do
  use Ecto.Migration

  def change do
    create table(:skill_scores) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :skill_class_id, references(:skill_classes, on_delete: :nothing), null: false
      add :level, :string, null: false
      add :percentage, :float, null: false

      timestamps()
    end

    create unique_index(:skill_scores, [:user_id, :skill_class_id])

    create table(:skill_score_items) do
      add :skill_id, references(:skills, on_delete: :nothing), null: false
      add :skill_score_id, references(:skill_scores, on_delete: :nothing), null: false
      add :score, :string

      timestamps()
    end

    create unique_index(:skill_score_items, [:skill_score_id, :skill_id])
  end
end
