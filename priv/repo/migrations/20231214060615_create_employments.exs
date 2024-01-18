defmodule Bright.Repo.Migrations.CreateEmployments do
  use Ecto.Migration

  def change do
    create table(:employments) do
      add :income, :integer
      add :message, :text
      add :skill_panel_name, :string
      add :desired_income, :integer
      add :skill_params, :text
      add :status, :string
      add :recruiter_reason, :string
      add :candidates_reason, :string
      add :recruiter_user_id, references(:users, on_delete: :nothing)
      add :candidates_user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:employments, [:recruiter_user_id])
    create index(:employments, [:candidates_user_id])
  end
end
