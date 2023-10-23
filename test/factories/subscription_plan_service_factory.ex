defmodule Bright.SubscriptionPlanServiceFactory do
  @moduledoc """
  Factory for Bright.SubscriptionServicePlanFactory
  """

  defmacro __using__(_opts) do
    quote do
      def subscription_plan_services_factory do
        %Bright.Subscriptions.SubscriptionPlanService{
          subscription_plan: build(:subscription_plans),
          service_code: sequence(:service_code, &"service_code_#{&1}")
        }
      end
    end
  end
end
