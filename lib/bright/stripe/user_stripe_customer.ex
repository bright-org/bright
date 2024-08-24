defmodule Bright.Stripe.UserStripeCustomer do
  @moduledoc """
  Stripeの顧客情報を扱うスキーマ
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "user_stripe_customers" do
    field :stripe_customer_id, :string
    belongs_to :user, Bright.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(user_stripe_customer, attrs) do
    user_stripe_customer
    |> cast(attrs, [:stripe_customer_id, :user_id])
    |> validate_required([:stripe_customer_id, :user_id])
    |> unique_constraint(:stripe_customer_id)
  end
end
