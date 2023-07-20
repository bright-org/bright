defmodule Bright.Repo.Migrations.CreateUserJobProfiles do
  use Ecto.Migration

  def change do
    create table(:user_job_profiles) do
      add :job_searching, :boolean, default: false, null: false
      add :wish_employed, :boolean, default: false, null: false
      add :wish_change_job, :boolean, default: false, null: false
      add :wish_side_job, :boolean, default: false, null: false
      add :wish_freelance, :boolean, default: false, null: false
      add :availability_date, :naive_datetime
      add :office_work, :boolean, default: false, null: false
      add :office_work_holidays, :boolean, default: false, null: false
      add :office_pred, :integer
      add :office_operating_time, :integer
      add :remove_work, :boolean, default: false, null: false
      add :remote_work_holidays, :boolean, default: false, null: false
      add :remote_operating_time, :integer
      add :desired_income, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_job_profiles, [:user_id])
  end
end
