defmodule Bright.Repo.Migrations.CreateSkillEvidences do
  use Ecto.Migration

  def change do
    create table(:skill_evidences) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :skill_id, references(:skills, on_delete: :nothing), null: false
      add :progress, :integer, null: false

      timestamps()
    end

    create unique_index(:skill_evidences, [:user_id, :skill_id])
  end
end
