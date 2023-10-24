defmodule Bright.Repo.Migrations.CreateTeamSupporterTeams do
  use Ecto.Migration

  def change do
    create table(:team_supporter_teams) do
      add :supportee_team_id, references(:teams, on_delete: :nothing), null: false
      add :supporter_team_id, references(:teams, on_delete: :nothing)
      add :request_from_user_id, references(:users, on_delete: :nothing), null: false
      add :request_to_user_id, references(:users, on_delete: :nothing), null: false
      add :status, :string, null: false
      add :request_datetime, :naive_datetime, null: false
      add :start_datetime, :naive_datetime
      add :end_datetime, :naive_datetime

      timestamps()
    end

    create unique_index(:team_supporter_teams, [
             :supportee_team_id,
             :supporter_team_id,
             :request_datetime
           ])

    create index(:team_supporter_teams, [:request_from_user_id, :status])
    create index(:team_supporter_teams, [:request_to_user_id, :status])
  end
end
