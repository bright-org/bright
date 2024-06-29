defmodule Bright.SubscriptionUserPlanFactory do
  @moduledoc """
  Factory for Bright.SubscriptionUserPlanFactory
  """

  defmacro __using__(_opts) do
    quote do
      def subscription_user_plan_subscription_end_with_free_trial_factory do
        %Bright.Subscriptions.SubscriptionUserPlan{
          user: build(:user),
          subscription_plan: build(:subscription_plans),
          subscription_status: :subscription_ended,
          trial_start_datetime: NaiveDateTime.utc_now(),
          subscription_start_datetime: NaiveDateTime.utc_now(),
          trial_end_datetime: NaiveDateTime.utc_now(),
          subscription_end_datetime: NaiveDateTime.utc_now()
        }
      end

      def subscription_user_plan_subscription_end_with_free_trial(
            %Bright.Accounts.User{} = user,
            %Bright.Subscriptions.SubscriptionPlan{} = subscription_plan
          ) do
        insert(:subscription_user_plan_subscription_end_with_free_trial,
          user: user,
          subscription_plan: subscription_plan
        )

        subscription_plan
      end

      def subscription_user_plan_subscription_end_without_free_trial_factory do
        %Bright.Subscriptions.SubscriptionUserPlan{
          user: build(:user),
          subscription_plan: build(:subscription_plans),
          subscription_status: :subscription_ended,
          trial_start_datetime: nil,
          subscription_start_datetime: NaiveDateTime.utc_now(),
          trial_end_datetime: nil,
          subscription_end_datetime: NaiveDateTime.utc_now()
        }
      end

      def subscription_user_plan_subscription_end_without_free_trial(
            %Bright.Accounts.User{} = user,
            %Bright.Subscriptions.SubscriptionPlan{} = subscription_plan
          ) do
        insert(:subscription_user_plan_subscription_end_without_free_trial,
          user: user,
          subscription_plan: subscription_plan
        )

        subscription_plan
      end

      def subscription_user_plan_subscribing_with_free_trial_factory do
        %Bright.Subscriptions.SubscriptionUserPlan{
          user: build(:user),
          subscription_plan: build(:subscription_plans),
          subscription_status: :subscribing,
          trial_start_datetime: NaiveDateTime.utc_now(),
          subscription_start_datetime: NaiveDateTime.utc_now(),
          trial_end_datetime: NaiveDateTime.utc_now(),
          subscription_end_datetime: nil
        }
      end

      def subscription_user_plan_subscribing_with_free_trial(
            %Bright.Accounts.User{} = user,
            %Bright.Subscriptions.SubscriptionPlan{} = subscription_plan
          ) do
        insert(:subscription_user_plan_subscribing_with_free_trial,
          user: user,
          subscription_plan: subscription_plan
        )

        subscription_plan
      end

      def subscription_user_plan_subscribing_without_free_trial_factory do
        %Bright.Subscriptions.SubscriptionUserPlan{
          user: build(:user),
          subscription_plan: build(:subscription_plans),
          subscription_status: :subscribing,
          trial_start_datetime: nil,
          subscription_start_datetime: NaiveDateTime.utc_now(),
          trial_end_datetime: nil,
          subscription_end_datetime: nil
        }
      end

      def subscription_user_plan_subscribing_without_free_trial(
            %Bright.Accounts.User{} = user,
            %Bright.Subscriptions.SubscriptionPlan{} = subscription_plan
          ) do
        insert(:subscription_user_plan_subscribing_without_free_trial,
          user: user,
          subscription_plan: subscription_plan
        )

        subscription_plan
      end

      def subscription_user_plan_free_trial_factory do
        %Bright.Subscriptions.SubscriptionUserPlan{
          user: build(:user),
          subscription_plan: build(:subscription_plans),
          subscription_status: :free_trial,
          trial_start_datetime: NaiveDateTime.utc_now(),
          subscription_start_datetime: nil,
          trial_end_datetime: nil,
          subscription_end_datetime: nil
        }
      end

      def subscription_user_plan_free_trial(
            %Bright.Accounts.User{} = user,
            %Bright.Subscriptions.SubscriptionPlan{} = subscription_plan
          ) do
        insert(:subscription_user_plan_free_trial,
          user: user,
          subscription_plan: subscription_plan
        )

        subscription_plan
      end

      def subscription_user_plan_free_trial_end(
            %Bright.Accounts.User{} = user,
            %Bright.Subscriptions.SubscriptionPlan{} = subscription_plan
          ) do
        insert(:subscription_user_plan_free_trial,
          user: user,
          subscription_plan: subscription_plan,
          trial_start_datetime: NaiveDateTime.utc_now(),
          trial_end_datetime: NaiveDateTime.utc_now()
        )

        subscription_plan
      end
    end
  end
end
