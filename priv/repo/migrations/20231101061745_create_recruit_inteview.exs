defmodule Bright.Repo.Migrations.CreateRecruitInteview do
  use Ecto.Migration

  def change do
    create table(:recruit_inteview) do
      add :skill_params, :text
      add :comment, :string
      add :status, :string
      add :interview_user_id, references(:users, on_delete: :nothing)
      add :recruiter_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:recruit_inteview, [:interview_user_id])
    create index(:recruit_inteview, [:recruiter_id])
  end
end
