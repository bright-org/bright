defmodule Bright.Repo.Migrations.DropCommunities do
  use Ecto.Migration

  def up do
    drop_if_exists table(:communities)
  end

  # Bright.Repo.Migrations.CreateCommunities
  def down do
    create table(:communities) do
      add :name, :string, null: false

      timestamps()
    end
  end
end
