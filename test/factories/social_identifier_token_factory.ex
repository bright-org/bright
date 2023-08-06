defmodule Bright.SocialIdentifierTokenFactory do
  @moduledoc """
  Factory for Bright.Accounts.SocialIdentifierToken
  """

  defmacro __using__(_opts) do
    quote do
      def social_identifier_token_factory do
        %Bright.Accounts.SocialIdentifierToken{
          name: sequence(:name, &"user_name_#{&1}"),
          email: sequence(:email, &"user#{&1}@example.com"),
          identifier: sequence(:identifier, &"#{&1}"),
          token: "token"
        }
      end

      def social_identifier_token_for_google_factory do
        build(:social_identifier_token, provider: :google)
      end
    end
  end
end
