defmodule Bright.Repo.Migrations.CreateSkillExams do
  use Ecto.Migration

  def change do
    create table(:skill_exams) do
      add :skill_id, references(:skills, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:skill_exams, [:skill_id])
  end
end
