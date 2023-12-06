defmodule Bright.Repo.Migrations.CreateRecruitCoordinations do
  use Ecto.Migration

  def change do
    create table(:coordinations) do
      add :skill_panel_name, :string
      add :desired_income, :integer
      add :comment, :string
      add :skill_params, :text
      add :cancel_reason, :string
      add :status, :string
      add :candidates_user_id, references(:users, on_delete: :nothing)
      add :recruiter_user_id, references(:users, on_delete: :nothing)
      add :requestor_user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:coordinations, [:candidates_user_id])
    create index(:coordinations, [:recruiter_user_id])
    create index(:coordinations, [:requestor_user_id])
    create index(:coordinations, [:status])
  end
end
