defmodule Bright.Repo.Migrations.AddBecameAtToSkillClassScores do
  use Ecto.Migration

  def change do
    alter table(:skill_class_scores) do
      add :became_normal_at, :naive_datetime
      add :became_skilled_at, :naive_datetime
    end
  end
end
