defmodule Bright.Repo.Migrations.AddStripeSubscriptionIdToSubscriptionUserPlans do
  use Ecto.Migration

  def change do
    alter table(:subscription_user_plans) do
      add :stripe_subscription_id, :string
    end
  end
end
