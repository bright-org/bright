defmodule Bright.Repo.Migrations.AddSkillReferencesUrl do
  use Ecto.Migration

  def change do
    alter table(:skill_references) do
      add :url, :string
    end
  end
end
