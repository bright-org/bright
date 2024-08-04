defmodule Bright.StripeFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Stripe` context.
  """

  @doc """
  Generate a stripe_price.
  """
  def stripe_price_fixture(attrs \\ %{}) do
    {:ok, stripe_price} =
      attrs
      |> Enum.into(%{
        stripe_lookup_key: "some stripe_lookup_key",
        stripe_price_id: "some stripe_price_id"
      })
      |> Bright.Stripe.create_stripe_price()

    stripe_price
  end
end
