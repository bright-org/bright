defmodule Bright.Repo.Migrations.CreateTeamMemberUsers do
  use Ecto.Migration

  def change do
    create table(:team_member_users) do
      add :user_id, :uuid, references(:users, on_delete: :nothing)
      add :team_id, :uuid, references(:teams, on_delete: :nothing)
      add :is_admin, :boolean, default: false, null: false
      add :is_primary, :boolean, default: false, null: false

      timestamps()
    end
  end
end
