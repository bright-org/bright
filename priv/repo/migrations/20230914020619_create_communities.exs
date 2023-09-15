defmodule Bright.Repo.Migrations.CreateCommunities do
  use Ecto.Migration

  def change do
    create table(:communities) do
      add :name, :string, null: false

      timestamps()
    end
  end
end
