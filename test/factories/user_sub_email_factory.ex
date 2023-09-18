defmodule Bright.UserSubEmailFactory do
  @moduledoc """
  Factory for Bright.Accounts.UserSubEmailFactory
  """

  defmacro __using__(_opts) do
    quote do
      def user_sub_email_factory do
        %Bright.Accounts.UserSubEmail{
          user: build(:user),
          email: sequence(:email, &"user_sub_#{&1}@example.com")
        }
      end
    end
  end
end
