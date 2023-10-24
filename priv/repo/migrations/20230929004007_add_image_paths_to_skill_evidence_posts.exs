defmodule Bright.Repo.Migrations.AddImagePathsToSkillEvidencePosts do
  use Ecto.Migration

  def change do
    alter table(:skill_evidence_posts) do
      add :image_paths, {:array, :string}
    end
  end
end
