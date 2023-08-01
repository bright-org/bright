defmodule Bright.Repo.Migrations.CreateCareerFieldScores do
  use Ecto.Migration

  def change do
    create table(:career_field_scores) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :career_field_id, references(:career_fields, on_delete: :nothing), null: false
      add :percentage, :float, null: false

      timestamps()
    end

    create unique_index(:career_field_scores, [:user_id, :career_field_id])
  end
end
