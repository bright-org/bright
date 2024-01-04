defmodule Bright.Repo.Migrations.AddAuthorizationPriorityToSubscriptionPlans do
  use Ecto.Migration

  def up do
    alter table(:subscription_plans) do
      add :authorization_priority, :integer
    end

    # カラム初期化
    # migration時点において、free_trial_priorityと同値で問題ないため実施
    execute "UPDATE subscription_plans SET authorization_priority = free_trial_priority"
  end

  def down do
    alter table(:subscription_plans) do
      remove :authorization_priority, :integer
    end
  end
end
