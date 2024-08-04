defmodule Bright.Zoho.MockAuthSetup do
  @moduledoc """
  Zoho の認証 API のモックをセットアップする

  use Bright.Zoho.MockAuthSetup

  @tag zoho_auth_mock: :auth_success
  test "xxx" do
    xxx
  end
  """

  use ExUnit.Callbacks

  defmacro __using__(_opts) do
    quote do
      import Bright.Zoho.MockAuthSetup
      setup :mock_auth_setup
    end
  end

  def mock_auth_setup(%{zoho_auth_mock: :auth_success}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "access_token" => "xxxxx",
            "expires_in" => 3600,
            "api_domain" => "https://www.zohoapis.jp"
          }
        }
    end)
  end

  def mock_auth_setup(%{zoho_auth_mock: :auth_failure}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        %Tesla.Env{
          status: 200,
          body: %{"error" => "invalid_client"}
        }
    end)
  end

  def mock_auth_setup(%{zoho_auth_mock: :auth_connection_refused}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        {:error, :econnrefused}
    end)
  end

  def mock_auth_setup(_), do: :ok
end
