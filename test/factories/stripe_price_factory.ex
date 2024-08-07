defmodule Bright.StripePriceFactory do
  @moduledoc """
  Factory for Bright.StripePriceFactory
  """

  defmacro __using__(_opts) do
    quote do
      def stripe_price_factory do
        %Bright.Stripe.StripePrice{
          stripe_price_id: sequence(:stripe_price_id, &"stripe_price_id#{&1}"),
          stripe_lookup_key: "default",
          subscription_plan: build(:subscription_plans)
        }
      end

      def stripe_price(%Bright.Subscriptions.SubscriptionPlan{} = subscription_plan) do
        insert(:stripe_price, subscription_plan: subscription_plan)

        subscription_plan
      end
    end
  end
end
