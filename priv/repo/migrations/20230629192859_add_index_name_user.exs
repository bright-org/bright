defmodule Bright.Repo.Migrations.AddIndexNameUser do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:name])
  end
end
