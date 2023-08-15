defmodule Bright.Repo.Migrations.CreateHistoricalSkillScores do
  use Ecto.Migration

  def change do
    create table(:historical_skill_scores) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :historical_skill_id, references(:historical_skills, on_delete: :nothing), null: false

      add :score, :string

      timestamps()
    end
  end
end
