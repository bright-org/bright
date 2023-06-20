defmodule Bright.Repo.Migrations.CreateUserJoinedTeams do
  use Ecto.Migration

  def change do
    create table(:user_joined_teams) do
      add :bright_user_id, :integer
      add :team_id, :integer
      add :is_auther, :boolean, default: false, null: false
      add :is_primary_team, :boolean, default: false, null: false

      timestamps()
    end
  end
end
