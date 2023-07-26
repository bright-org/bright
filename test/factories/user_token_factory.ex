defmodule Bright.UserTokenFactory do
  @moduledoc """
  Factory for Bright.Accounts.UserToken
  """

  defmacro __using__(_opts) do
    quote do
      def user_token_factory do
        %Bright.Accounts.UserToken{
          user: build(:user)
        }
      end

      def extract_user_token(fun) do
        {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
        [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
        token
      end
    end
  end
end
