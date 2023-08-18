defmodule Bright.Repo.Migrations.AlterUniqueIndexOnSkillClasses do
  use Ecto.Migration

  def change do
    drop index(:skill_classes, [:skill_panel_id, :class], unique: true)
    create index(:skill_classes, [:skill_panel_id, :class, :locked_date], unique: true)
  end
end
