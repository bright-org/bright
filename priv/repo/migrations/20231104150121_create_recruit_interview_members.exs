defmodule Bright.Repo.Migrations.CreateRecruitInterviewMembers do
  use Ecto.Migration

  def change do
    create table(:recruit_interview_members) do
      add :decision, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :recruit_interview_id, references(:recruit_interviews, on_delete: :nothing)

      timestamps()
    end

    create index(:recruit_interview_members, [:user_id])
    create index(:recruit_interview_members, [:recruit_interview_id])
  end
end
