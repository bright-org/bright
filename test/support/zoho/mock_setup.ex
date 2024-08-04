defmodule Bright.Zoho.MockSetup do
  @moduledoc """
  Zoho CRM API のモックをセットアップする

  use Bright.Zoho.MockSetup

  @tag zoho_crm_mock: :create_contact_success
  test "xxx" do
    xxx
  end
  """

  use ExUnit.Callbacks

  defmacro __using__(_opts) do
    quote do
      import Bright.Zoho.MockSetup
      setup :mock_zoho_api
    end
  end

  defp auth_success_response do
    %Tesla.Env{
      status: 200,
      body: %{
        "access_token" => "xxxxx",
        "expires_in" => 3600,
        "api_domain" => "https://www.zohoapis.jp"
      }
    }
  end

  def mock_zoho_api(%{zoho_mock: :auth_success}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} -> auth_success_response()
    end)
  end

  def mock_zoho_api(%{zoho_mock: :auth_failure}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        %Tesla.Env{
          status: 200,
          body: %{"error" => "invalid_client"}
        }
    end)
  end

  def mock_zoho_api(%{zoho_mock: :auth_server_error}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        %Tesla.Env{
          status: 500,
          body: %{"error" => "server_error"}
        }
    end)
  end

  def mock_zoho_api(%{zoho_mock: :auth_connection_refused}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        {:error, :econnrefused}
    end)
  end

  def mock_zoho_api(%{zoho_mock: :create_contact_success}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        auth_success_response()

      %{method: :post, url: "https://www.zohoapis.jp/crm/v6/Contacts"} ->
        %Tesla.Env{
          status: 201,
          body: %{
            "data" => [
              %{
                "code" => "SUCCESS",
                "details" => %{
                  "id" => "100",
                  "Created_Time" => "2024-08-05T00:00:00+09:00",
                  "Modified_Time" => "2024-08-05T00:00:00+09:00"
                },
                "message" => "record added",
                "status" => "success"
              }
            ]
          }
        }
    end)
  end

  def mock_zoho_api(%{zoho_mock: :create_contact_failure}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        auth_success_response()

      %{method: :post, url: "https://www.zohoapis.jp/crm/v6/Contacts"} ->
        %Tesla.Env{
          status: 400,
          body: %{
            "data" => [
              %{
                "code" => "MANDATORY_NOT_FOUND",
                "details" => %{},
                "message" => "required field not found",
                "status" => "error"
              }
            ]
          }
        }
    end)
  end

  def mock_zoho_api(%{zoho_mock: :create_contact_connection_refused}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        auth_success_response()

      %{method: :post, url: "https://www.zohoapis.jp/crm/v6/Contacts"} ->
        {:error, :econnrefused}
    end)
  end

  def mock_zoho_api(_), do: :ok
end
