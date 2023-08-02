defmodule Bright.Repo.Migrations.CreateSkillUnitScores do
  use Ecto.Migration

  def change do
    create table(:skill_unit_scores) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :skill_unit_id, references(:skill_units, on_delete: :nothing), null: false
      add :percentage, :float, null: false

      timestamps()
    end

    create unique_index(:skill_unit_scores, [:user_id, :skill_unit_id])
  end
end
