defmodule Bright.Repo.Migrations.AddRankAndDescriptionToJobs do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :rank, :string, null: false, default: "basic"
      add :description, :string
    end
  end
end
