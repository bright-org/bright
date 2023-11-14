defmodule Bright.Repo.Migrations.CreateRecruitInterview do
  use Ecto.Migration

  def change do
    create table(:interviews) do
      add :skill_params, :text
      add :comment, :string
      add :status, :string
      add :candidates_user_id, references(:users, on_delete: :nothing)
      add :recruiter_user_id, references(:users, on_delete: :nothing)
      add :requestor_user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:interviews, [:recruiter_user_id])
    create index(:interviews, [:candidates_user_id])
    create index(:interviews, [:requestor_user_id])
    create index(:interviews, [:status])
  end
end
