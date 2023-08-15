defmodule Bright.Repo.Migrations.CreateHistoricalSkillUnitScores do
  use Ecto.Migration

  def change do
    create table(:historical_skill_unit_scores) do
      add :user_id, references(:users, on_delete: :nothing), null: false

      add :historical_skill_unit_id, references(:historical_skill_units, on_delete: :nothing),
        null: false

      add :locked_date, :date, null: false
      add :percentage, :float, null: false

      timestamps()
    end
  end
end
