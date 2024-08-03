defmodule Bright.Repo.Migrations.CreateUserStripeCustomers do
  use Ecto.Migration

  def change do
    create table(:user_stripe_customers) do
      add :stripe_customer_id, :string, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:user_stripe_customers, [:user_id])
    create unique_index(:user_stripe_customers, [:stripe_customer_id])
  end
end
