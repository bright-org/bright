defmodule Bright.Repo.Migrations.AddTeamEnableTeamUpFunctions do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :enable_team_up_functions, :boolean, default: false, null: false
    end
  end
end
