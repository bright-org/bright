defmodule Bright.Repo.Migrations.CreateRecruitInterviewMembers do
  use Ecto.Migration

  def change do
    create table(:interview_members) do
      add :decision, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :interview_id, references(:interviews, on_delete: :nothing)

      timestamps()
    end

    create index(:interview_members, [:user_id])
    create index(:interview_members, [:interview_id])
  end
end
