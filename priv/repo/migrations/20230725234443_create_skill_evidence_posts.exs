defmodule Bright.Repo.Migrations.CreateSkillEvidencePosts do
  use Ecto.Migration

  def change do
    create table(:skill_evidence_posts) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :skill_evidence_id, references(:skill_evidences, on_delete: :nothing), null: false
      add :content, :text, null: false

      timestamps()
    end

    create index(:skill_evidence_posts, [:skill_evidence_id, :inserted_at])
    create index(:skill_evidence_posts, [:user_id, :inserted_at])
  end
end
