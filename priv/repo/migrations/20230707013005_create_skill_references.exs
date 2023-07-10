defmodule Bright.Repo.Migrations.CreateSkillReferences do
  use Ecto.Migration

  def change do
    create table(:skill_references) do
      add :skill_id, references(:skills, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:skill_references, [:skill_id])
  end
end
