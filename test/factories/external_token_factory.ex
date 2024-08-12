defmodule Bright.ExternalTokenFactory do
  @moduledoc """
  Factory for Bright.Externals.ExternalToken
  """

  defmacro __using__(_opts) do
    quote do
      def external_token_factory do
        %Bright.Externals.ExternalToken{
          token: "token",
          token_type: :ZOHO_CRM,
          api_domain: "https://accounts.zoho.jp",
          expired_at: NaiveDateTime.utc_now() |> NaiveDateTime.add(3600, :second)
        }
      end
    end
  end
end
