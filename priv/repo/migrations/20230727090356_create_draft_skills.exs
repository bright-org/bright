defmodule Bright.Repo.Migrations.CreateDraftSkills do
  use Ecto.Migration

  def change do
    create table(:draft_skills) do
      add :draft_skill_category_id, references(:draft_skill_categories, on_delete: :nothing),
        null: false

      add :trace_id, :uuid, null: false
      add :name, :string, null: false
      add :position, :integer, null: false

      timestamps()
    end

    create unique_index(:draft_skills, [:draft_skill_category_id, :position])
    create unique_index(:draft_skills, [:trace_id])
  end
end
