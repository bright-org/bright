defmodule Bright.Repo.Migrations.CreateHistoricalSkillCategories do
  use Ecto.Migration

  def change do
    create table(:historical_skill_categories) do
      add :historical_skill_unit_id, references(:historical_skill_units, on_delete: :nothing),
        null: false

      add :trace_id, :uuid, null: false
      add :name, :string, null: false
      add :position, :integer, null: false

      timestamps()
    end

    create index(:historical_skill_categories, [:historical_skill_unit_id])
    create index(:historical_skill_categories, [:trace_id])
    create index(:historical_skill_categories, [:position])
  end
end
