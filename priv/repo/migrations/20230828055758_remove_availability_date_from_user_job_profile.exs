defmodule Bright.Repo.Migrations.RemoveAvailabilityDateFromUserJobProfile do
  use Ecto.Migration

  def change do
    alter table(:user_job_profiles) do
      remove :availability_date, :date
    end
  end
end
