defmodule Bright.Repo.Migrations.UsersAddPasswordRegistered do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_registered, :boolean, default: true, null: false
    end
  end
end
