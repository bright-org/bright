defmodule Bright.UserSocialAuthFactory do
  @moduledoc """
  Factory for Bright.Accounts.UserSocialAuth
  """

  defmacro __using__(_opts) do
    quote do
      def user_social_auth_factory do
        %Bright.Accounts.UserSocialAuth{
          identifier: sequence(:identifier, &"#{&1}"),
          user: build(:user)
        }
      end

      def user_social_auth_for_google_factory do
        build(:user_social_auth, provider: :google)
      end
    end
  end
end
