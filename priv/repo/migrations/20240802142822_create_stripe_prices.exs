defmodule Bright.Repo.Migrations.CreateStripePrices do
  use Ecto.Migration

  def change do
    create table(:stripe_prices) do
      add :stripe_price_id, :string, null: false
      add :stripe_lookup_key, :string, null: false
      add :subscription_plan_id, references(:subscription_plans, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:stripe_prices, [:subscription_plan_id])
  end
end
