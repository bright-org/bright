defmodule Bright.Repo.Migrations.DropSkillExamResults do
  use Ecto.Migration

  # 唯一の情報をskill_scoresに移したので削除

  def up do
    drop index(:skill_exam_results, [:user_id, :skill_id])
    drop index(:skill_exam_results, [:skill_exam_id])
    drop table(:skill_exam_results)
  end

  def down do
    create table(:skill_exam_results) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :skill_id, references(:skills, on_delete: :nothing), null: false
      add :skill_exam_id, references(:skill_exams, on_delete: :nothing), null: false
      add :progress, :string, null: false

      timestamps()
    end

    create unique_index(:skill_exam_results, [:user_id, :skill_id])
    create index(:skill_exam_results, [:skill_exam_id])
  end
end
