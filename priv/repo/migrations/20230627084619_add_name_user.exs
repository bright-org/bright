defmodule Bright.Repo.Migrations.AddNameUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
    end
  end
end
