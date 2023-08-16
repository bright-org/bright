defmodule Bright.Repo.Migrations.CreateUserJobProfiles do
  use Ecto.Migration

  def change do
    create table(:user_job_profiles) do
      add :job_searching, :boolean, default: false, null: false
      add :wish_employed, :boolean, default: false, null: false
      add :wish_change_job, :boolean, default: false, null: false
      add :wish_side_job, :boolean, default: false, null: false
      add :wish_freelance, :boolean, default: false, null: false
      add :availability_date, :date
      add :office_work, :boolean, default: false, null: false
      add :office_work_holidays, :boolean, default: false, null: false
      add :office_pref, :string
      add :office_working_hours, :string
      add :remove_work, :boolean, default: false, null: false
      add :remote_work_holidays, :boolean, default: false, null: false
      add :remote_working_hours, :string
      add :desired_income, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_job_profiles, [:user_id])
  end
end
