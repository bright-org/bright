defmodule Bright.Repo.Migrations.CreateDraftSkillUnits do
  use Ecto.Migration

  def change do
    create table(:draft_skill_units) do
      add :trace_id, :uuid, null: false
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:draft_skill_units, [:trace_id])
  end
end
