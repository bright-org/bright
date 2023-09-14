defmodule Bright.Repo.Migrations.CreateCommunities do
  use Ecto.Migration

  def change do
    create table(:communities) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :community_id, references(:notification_communities, on_delete: :nothing), null: false
      add :name, :string
      add :participation, :boolean, default: false, null: false

      timestamps()
    end
  end
end
