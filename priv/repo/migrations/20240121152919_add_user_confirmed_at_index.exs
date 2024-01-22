defmodule Bright.Repo.Migrations.AddUserConfirmedAtIndex do
  use Ecto.Migration

  def change do
    create index(:users, [:confirmed_at])
  end
end
