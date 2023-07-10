defmodule Bright.Repo.Migrations.RenameSkillClassesRank do
  use Ecto.Migration

  def change do
    rename table("skill_classes"), :rank, to: :class

    rename index(:skill_classes, [:skill_panel_id, :rank]),
      to: "skill_classes_skill_panel_id_class_index"
  end
end
