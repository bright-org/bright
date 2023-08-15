defmodule Bright.Repo.Migrations.RenameSkillScoresToSkillClassScores do
  use Ecto.Migration

  # リネームを実施
  # skill_scores => skill_class_scores
  # skill_score_items => skill_scores
  #
  # 上記２つは他テーブルの外部キーになっていないため、
  # 簡略化して、テーブル名変更ではなくテーブルごと削除と作成を実施

  def up do
    drop index(:skill_score_items, [:skill_score_id, :skill_id])
    drop table(:skill_score_items)

    drop index(:skill_scores, [:user_id, :skill_class_id])
    drop table(:skill_scores)

    create table(:skill_class_scores) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :skill_class_id, references(:skill_classes, on_delete: :nothing), null: false
      add :level, :string, null: false
      add :percentage, :float, null: false

      timestamps()
    end

    create unique_index(:skill_class_scores, [:user_id, :skill_class_id])

    create table(:skill_scores) do
      add :skill_id, references(:skills, on_delete: :nothing), null: false
      add :skill_class_score_id, references(:skill_class_scores, on_delete: :nothing), null: false
      add :score, :string

      timestamps()
    end

    create unique_index(:skill_scores, [:skill_class_score_id, :skill_id])
  end

  def down do
    drop index(:skill_scores, [:skill_class_score_id, :skill_id])
    drop table(:skill_scores)

    drop index(:skill_class_scores, [:user_id, :skill_class_id])
    drop table(:skill_class_scores)

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
