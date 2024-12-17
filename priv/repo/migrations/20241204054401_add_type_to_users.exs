defmodule Bright.Repo.Migrations.AddTypeToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :type, :string, null: false, default: "engineer"
    end
  end
end
