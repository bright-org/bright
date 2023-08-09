defmodule Bright.Repo.Migrations.CreateHistoricalCareerFieldScores do
  use Ecto.Migration

  def change do
    create table(:historical_career_field_scores) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :career_field_id, references(:career_fields, on_delete: :nothing), null: false
      add :locked_date, :date, null: false
      add :percentage, :float, null: false
      add :high_skills_count, :integer, null: false

      timestamps()
    end
  end
end
