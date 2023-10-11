defmodule Bright.Repo.Migrations.CreateSubscriptionUserPlans do
  use Ecto.Migration

  def change do
    create table(:subscription_user_plans) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :subscription_plan_id, references(:subscription_plans, on_delete: :nothing), null: false
      add :subscription_status, :string
      add :subscription_start_datetime, :naive_datetime
      add :subscription_end_datetime, :naive_datetime
      add :trial_start_datetime, :naive_datetime
      add :trial_end_datetime, :naive_datetime

      timestamps()
    end

    create unique_index(:subscription_user_plans, [
             :user_id,
             :subscription_plan_id,
             :subscription_start_datetime
           ])

    create index(:subscription_user_plans, [:subscription_plan_id, :subscription_status, :user_id])
  end
end
