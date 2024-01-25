defmodule Bright.SubscriptionPlanFactory do
  @moduledoc """
  Factory for Bright.SubscriptionPlanFactory
  """

  defmacro __using__(_opts) do
    quote do
      def subscription_plans_factory do
        %Bright.Subscriptions.SubscriptionPlan{
          plan_code: sequence(:plan_code, &"plan_code_#{&1}"),
          name_jp: sequence(:name_jp, &"plan_name_#{&1}"),
          create_teams_limit: Enum.random(0..15),
          create_enable_hr_functions_teams_limit: Enum.random(0..2),
          team_members_limit: Enum.random(0..15),
          free_trial_priority: Enum.random(0..15),
          authorization_priority: Enum.random(0..15)
        }
      end

      def plan_with_plan_service(%Bright.Subscriptions.SubscriptionPlan{} = subscription_plan) do
        insert(:subscription_plan_services, subscription_plan: subscription_plan)
        subscription_plan
      end

      def plan_with_plan_service_by_service_code(
            %Bright.Subscriptions.SubscriptionPlan{} = subscription_plan,
            service_code
          ) do
        insert(
          :subscription_plan_services,
          %{subscription_plan: subscription_plan, service_code: service_code}
        )

        subscription_plan
      end

      def plan_with_plan_services_by_service_codes(
            %Bright.Subscriptions.SubscriptionPlan{} = subscription_plan,
            service_codes
          ) do
        subscription_plan_services =
          service_codes
          |> Enum.map(fn service_code ->
            insert(
              :subscription_plan_services,
              %{subscription_plan: subscription_plan, service_code: service_code}
            )
          end)

        subscription_plan
        |> Map.put(:subscription_plan_services, subscription_plan_services)
      end
    end
  end
end
