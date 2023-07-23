defmodule Bright.User2faCodeFactory do
  @moduledoc """
  Factory for Bright.Accounts.User2faCodes
  """

  defmacro __using__(_opts) do
    quote do
      def user2fa_code_factory do
        %Bright.Accounts.User2faCodes{
          user: build(:user),
          code: sequence(:code, &String.pad_leading("#{&1}", 6, "0")),
          sent_to: "dummy@example.com"
        }
      end
    end
  end
end
