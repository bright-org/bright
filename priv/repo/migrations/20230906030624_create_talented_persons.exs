defmodule Bright.Repo.Migrations.CreateTalentedPersons do
  use Ecto.Migration

  def change do
    create table(:talented_persons) do
      add :introducer_user_id, references(:users, on_delete: :nothing)
      add :fave_user_id, references(:users, on_delete: :nothing)
      add :team_id, references(:teams, on_delete: :nothing)
      add :fave_point, :text

      timestamps()
    end

    create index(:talented_persons, [:team_id])
  end
end
