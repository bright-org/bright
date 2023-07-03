defmodule Bright.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :enable_hr_functions, :boolean, default: false, null: false

      timestamps()
    end
  end
end
