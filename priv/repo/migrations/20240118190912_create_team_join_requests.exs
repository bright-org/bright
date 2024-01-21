defmodule Bright.Repo.Migrations.CreateTeamJoinRequests do
  use Ecto.Migration

  def change do
    create table(:team_join_requests) do
      add :status, :string
      add :comment, :text
      add :employment_id, references(:employments, on_delete: :nothing)
      add :team_owner_user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:team_join_requests, [:employment_id])
    create index(:team_join_requests, [:team_owner_user_id])
  end
end
