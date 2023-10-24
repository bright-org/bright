defmodule Bright.Repo.Migrations.CreateSubscriptionPlans do
  use Ecto.Migration

  def change do
    create table(:subscription_plans) do
      add :plan_code, :string
      add :name_jp, :string
      add :create_teams_limit, :integer
      add :create_enable_hr_functions_teams_limit, :integer
      add :team_members_limit, :integer
      add :available_contract_end_datetime, :naive_datetime
      add :free_trial_priority, :integer

      timestamps()
    end

    create unique_index(:subscription_plans, [:plan_code])
  end
end
