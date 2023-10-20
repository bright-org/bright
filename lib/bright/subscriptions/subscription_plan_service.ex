defmodule Bright.Subscriptions.SubscriptionPlanService do
  @moduledoc """
  サブスクリプションプランで利用可能なサービスを扱うスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "subscription_plan_services" do
    field :service_code, :string

    belongs_to :subscription_plan, Bright.Subscriptions.SubscriptionPlan

    timestamps()
  end

  @doc false
  def changeset(subscription_plan_service, attrs) do
    subscription_plan_service
    |> cast(attrs, [:service_code, :subscription_plan_id])
    |> validate_required([:service_code, :subscription_plan_id])
  end
end
