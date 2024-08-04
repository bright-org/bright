defmodule Bright.Stripe.StripePrice do
  @moduledoc """
  Stripeの商品価格を扱うスキーマ
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}

  schema "stripe_prices" do
    field :stripe_price_id, :string
    field :stripe_lookup_key, :string
    belongs_to :subscription_plan, Bright.Subscriptions.SubscriptionPlan, type: Ecto.ULID

    timestamps()
  end

  @doc false
  def changeset(stripe_price, attrs) do
    stripe_price
    |> cast(attrs, [:stripe_price_id, :stripe_lookup_key, :subscription_plan_id])
    |> validate_required([:stripe_price_id, :stripe_lookup_key, :subscription_plan_id])
  end
end
