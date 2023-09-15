defmodule Bright.Repo.Migrations.CreateCommunities do
  use Ecto.Migration

  def change do
    create table(:communities) do
      add :name, :string

      timestamps()
    end
  end
end
