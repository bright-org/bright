defmodule Bright.Repo.Migrations.AddSkillScoresUserId do
  use Ecto.Migration

  def up do
    drop index(:skill_scores, [:skill_class_score_id, :skill_id])
    drop table(:skill_scores)

    create table(:skill_scores) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :skill_id, references(:skills, on_delete: :nothing), null: false
      add :score, :string

      timestamps()
    end

    create unique_index(:skill_scores, [:user_id, :skill_id])
  end

  def down do
    drop index(:skill_scores, [:user_id, :skill_id])
    drop table(:skill_scores)

    create table(:skill_scores) do
      add :skill_id, references(:skills, on_delete: :nothing), null: false
      add :skill_class_score_id, references(:skill_class_scores, on_delete: :nothing), null: false
      add :score, :string

      timestamps()
    end

    create unique_index(:skill_scores, [:skill_class_score_id, :skill_id])
  end
end
