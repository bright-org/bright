defmodule Bright.Repo.Migrations.CreateSkillUnits do
  use Ecto.Migration

  def change do
    create table(:skill_units) do
      add :name, :string, null: false

      timestamps()
    end
  end
end
