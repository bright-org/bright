defmodule Bright.Repo.Migrations.CreateUserOnboardings do
  use Ecto.Migration

  def change do
    create table(:user_onboardings) do
      add :completed_at, :naive_datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_onboardings, [:user_id])
  end
end
