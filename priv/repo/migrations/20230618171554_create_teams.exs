defmodule Bright.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :team_name, :string
      add :enable_hr_functions, :boolean, default: false, null: false
      add :auther_bright_user_id, :integer

      timestamps()
    end
  end
end
