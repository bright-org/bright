defmodule Bright.Repo.Migrations.CreateHistoricalSkills do
  use Ecto.Migration

  def change do
    create table(:historical_skills) do
      add :historical_skill_category_id,
          references(:historical_skill_categories, on_delete: :nothing),
          null: false

      add :trace_id, :uuid, null: false
      add :name, :string, null: false
      add :position, :integer, null: false

      timestamps()
    end
  end
end
