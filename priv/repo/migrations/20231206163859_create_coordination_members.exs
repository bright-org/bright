defmodule Bright.Repo.Migrations.CreateCoordinationMembers do
  use Ecto.Migration

  def change do
    create table(:coordination_members) do
      add :decision, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :coordination_id, references(:coordinations, on_delete: :nothing)

      timestamps()
    end

    create index(:coordination_members, [:user_id])
    create index(:coordination_members, [:coordination_id])
  end
end
