defmodule Bright.Repo.Migrations.UsersNameNotNull do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :name, :string, null: false
    end
  end
end
