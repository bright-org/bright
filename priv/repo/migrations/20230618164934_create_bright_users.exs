defmodule Bright.Repo.Migrations.CreateBrightUsers do
  use Ecto.Migration

  def change do
    create table(:bright_users) do
      add :handle_name, :string
      add :email, :string
      add :password, :string

      timestamps()
    end
  end
end
