defmodule Bright.Repo.Migrations.CreateSkillExamResult do
  use Ecto.Migration

  def change do
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
