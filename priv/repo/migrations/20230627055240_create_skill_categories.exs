defmodule Bright.Repo.Migrations.CreateSkillCategories do
  use Ecto.Migration

  def change do
    create table(:skill_categories) do
      add :skill_unit_id, references(:skill_units, on_delete: :nothing), null: false
      add :name, :string, null: false
      add :position, :integer, null: false

      timestamps()
    end

    create unique_index(:skill_categories, [:skill_unit_id, :position])
  end
end
