defmodule Bright.UserOnboardingFactory do
  @moduledoc """
  Factory for Bright.Onboardings.UserOnboarding
  """

  defmacro __using__(_opts) do
    quote do
      def user_onboarding_factory do
        %Bright.Onboardings.UserOnboarding{
          user: build(:user),
          completed_at: NaiveDateTime.utc_now()
        }
      end
    end
  end
end
