defmodule Bright.Repo.Migrations.CreateStripePrices do
  use Ecto.Migration

  def change do
    create table(:stripe_prices) do
      add :stripe_price_id, :string
      add :stripe_lookup_key, :string
      add :subscription_plan_id, references(:subscription_plans, on_delete: :nothing)

      timestamps()
    end

    create index(:stripe_prices, [:subscription_plan_id])
  end
end
