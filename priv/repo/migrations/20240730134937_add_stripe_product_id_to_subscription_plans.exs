defmodule Bright.Repo.Migrations.AddStripeProductIdToSubscriptionPlans do
  use Ecto.Migration

  def change do
    alter table(:subscription_plans) do
      add :stripe_product_id, :string, null: false, default: "dummy_id"
    end
  end
end
