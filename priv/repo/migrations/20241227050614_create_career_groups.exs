defmodule Bright.Repo.Migrations.CreateCareerGroups do
  use Ecto.Migration

  def change do
    create table(:career_groups) do
      add :name, :string
      add :type, :string
      add :position, :integer

      timestamps()
    end
  end
end
