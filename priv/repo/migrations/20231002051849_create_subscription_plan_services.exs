defmodule Bright.Repo.Migrations.CreateSubscriptionPlanServices do
  use Ecto.Migration

  def change do
    create table(:subscription_plan_services) do
      add :service_code, :string
      add :subscription_plan_id, references(:subscription_plans, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:subscription_plan_services, [:subscription_plan_id, :service_code])
  end
end
