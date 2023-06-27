defmodule Bright.Repo.Migrations.CreateSkills do
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :skill_category_id, references(:skill_categories, on_delete: :nothing), null: false
      add :name, :string, null: false

      timestamps()
    end

    create index(:skills, [:skill_category_id])
  end
end
