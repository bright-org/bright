defmodule Bright.Repo.Migrations.CreateTeamMemberUsers do
  use Ecto.Migration

  def change do
    create table(:team_member_users) do
      add :user_id, references(:users, on_delete: :nothing)
      add :team_id, references(:teams, on_delete: :nothing)
      add :is_admin, :boolean, default: false, null: false
      add :is_primary, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:team_member_users, [:team_id, :user_id])
    create index(:team_member_users, [:user_id])
  end
end
