defmodule Bright.Repo.Migrations.CreateRecruitInterview do
  use Ecto.Migration

  def change do
    create table(:recruit_interviews) do
      add :skill_params, :text
      add :comment, :string
      add :status, :string
      add :recruitment_candidates_user_id, references(:users, on_delete: :nothing)
      add :recruiter_id, references(:users, on_delete: :nothing)
      add :requester_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:recruit_interviews, [:recruiter_id])
  end
end
