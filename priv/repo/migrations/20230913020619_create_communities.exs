defmodule Bright.Repo.Migrations.CreateCommunities do
  use Ecto.Migration

  def change do
    create table(:communities) do
      add :user_id, :uuid
      add :community_id, :uuid
      add :name, :string
      add :participation, :boolean, default: false, null: false

      timestamps()
    end
  end
end
