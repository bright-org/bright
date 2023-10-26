defmodule Bright.Repo.Migrations.AddDeletedAtToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :deleted_at, :naive_datetime
    end
  end
end
