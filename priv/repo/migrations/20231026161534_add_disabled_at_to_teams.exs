defmodule Bright.Repo.Migrations.AddDisabledAtToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :disabled_at, :naive_datetime
    end
  end
end
