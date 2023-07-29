defmodule Bright.Repo.Migrations.CreateDraftSkillCategories do
  use Ecto.Migration

  def change do
    create table(:draft_skill_categories) do
      add :draft_skill_unit_id, references(:draft_skill_units, on_delete: :nothing), null: false
      add :trace_id, :uuid, null: false
      add :name, :string, null: false
      add :position, :integer, null: false

      timestamps()
    end

    create unique_index(:draft_skill_categories, [:draft_skill_unit_id, :position])
    create unique_index(:draft_skill_categories, [:trace_id])
  end
end
