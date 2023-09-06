defmodule Bright.Repo.Migrations.CreateTalentedPersons do
  use Ecto.Migration

  def change do
    create table(:talented_persons) do
      add :introducer_user_id, :uuid
      add :fave_user_id, :uuid
      add :team_id, :uuid
      add :fave_point, :text

      timestamps()
    end
  end
end
