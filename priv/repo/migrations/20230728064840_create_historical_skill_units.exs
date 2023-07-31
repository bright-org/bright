defmodule Bright.Repo.Migrations.CreateHistoricalSkillUnits do
  use Ecto.Migration

  def change do
    create table(:historical_skill_units) do
      add :locked_date, :date, null: false
      add :trace_id, :uuid, null: false
      add :name, :string, null: false

      timestamps()
    end
  end
end
