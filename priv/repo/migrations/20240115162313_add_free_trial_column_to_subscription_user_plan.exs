defmodule Bright.Repo.Migrations.AddFreeTrialColumnToSubscriptionUserPlan do
  use Ecto.Migration

  def change do
    alter table(:subscription_user_plans) do
      add :company_name, :string
      add :phone_number, :string
      add :pic_name, :string
    end
  end
end
