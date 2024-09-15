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
        "access_token" => "new_token",
        "expires_in" => 3600,
        "api_domain" => "https://www.zohoapis.jp"
      }
    }
  end

  defp create_contact_success_response do
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
  end

  defp create_contact_failure_response do
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
  end

  defp search_contact_url(email) do
    "https://www.zohoapis.jp/crm/v6/Contacts/search?email=#{email}"
  end

  defp search_contact_success_response do
    %Tesla.Env{
      status: 200,
      body: %{
        "data" => [
          %{
            "id" => "100",
            "Last_Name" => "koyo2",
            "Created_Time" => "2024-08-05T00:00:00+09:00",
            "Modified_Time" => "2024-08-05T00:00:00+09:00"
          }
        ]
      }
    }
  end

  defp search_contact_missing_response do
    %Tesla.Env{
      status: 204,
      body: ""
    }
  end

  defp search_contanct_failure_response do
    %Tesla.Env{
      status: 400,
      body: %{
        "code" => "INVALID_DATA",
        "details" => %{},
        "message" =>
          "unable to process your request. please verify whether you have entered proper method name, parameter and parameter values.",
        "status" => "error"
      }
    }
  end

  defp update_contact_url(record_id) do
    "https://www.zohoapis.jp/crm/v6/Contacts/#{record_id}"
  end

  defp update_contact_success_response do
    %Tesla.Env{
      status: 200,
      body: %{
        "data" => [
          %{
            "code" => "SUCCESS",
            "details" => %{
              "id" => "100",
              "Created_Time" => "2024-08-05T00:00:00+09:00",
              "Modified_Time" => "2024-08-05T00:00:00+09:00"
            },
            "message" => "record updated",
            "status" => "success"
          }
        ]
      }
    }
  end

  defp update_contact_failure_response do
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
          body: %{}
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
        create_contact_success_response()
    end)
  end

  def mock_zoho_api(%{zoho_mock: :create_contact_success_without_token_request}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://www.zohoapis.jp/crm/v6/Contacts"} ->
        create_contact_success_response()
    end)
  end

  def mock_zoho_api(%{zoho_mock: :create_contact_failure}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        auth_success_response()

      %{method: :post, url: "https://www.zohoapis.jp/crm/v6/Contacts"} ->
        create_contact_failure_response()
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

  def mock_zoho_api(%{zoho_mock: {:search_contact_by_email_success, email}}) do
    search_contact_url = search_contact_url(email)

    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        auth_success_response()

      %{method: :get, url: ^search_contact_url} ->
        search_contact_success_response()
    end)
  end

  def mock_zoho_api(%{zoho_mock: {:search_contact_missing, email}}) do
    search_contact_url = search_contact_url(email)

    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        auth_success_response()

      %{method: :get, url: ^search_contact_url} ->
        search_contact_missing_response()
    end)
  end

  def mock_zoho_api(%{zoho_mock: {:search_contact_failure, email}}) do
    search_contact_url = search_contact_url(email)

    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        auth_success_response()

      %{method: :get, url: ^search_contact_url} ->
        search_contanct_failure_response()
    end)
  end

  def mock_zoho_api(%{zoho_mock: {:search_contact_connection_refused, email}}) do
    search_contact_url = search_contact_url(email)

    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        auth_success_response()

      %{method: :get, url: ^search_contact_url} ->
        {:error, :econnrefused}
    end)
  end

  def mock_zoho_api(%{zoho_mock: {:update_contact_success, record_id}}) do
    update_contact_url = update_contact_url(record_id)

    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        auth_success_response()

      %{method: :put, url: ^update_contact_url} ->
        update_contact_success_response()
    end)
  end

  def mock_zoho_api(%{zoho_mock: {:update_contact_failure, record_id}}) do
    update_contact_url = update_contact_url(record_id)

    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        auth_success_response()

      %{method: :put, url: ^update_contact_url} ->
        update_contact_failure_response()
    end)
  end

  def mock_zoho_api(%{zoho_mock: {:update_contact_connection_refused, record_id}}) do
    update_contact_url = update_contact_url(record_id)

    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        auth_success_response()

      %{method: :put, url: ^update_contact_url} ->
        {:error, :econnrefused}
    end)
  end

  def mock_zoho_api(%{
        zoho_mock: {:search_and_update_contact_success, %{email: email, record_id: record_id}}
      }) do
    search_contact_url = search_contact_url(email)
    update_contact_url = update_contact_url(record_id)

    Tesla.Mock.mock(fn
      %{method: :post, url: "https://accounts.zoho.jp/oauth/v2/token"} ->
        auth_success_response()

      %{method: :get, url: ^search_contact_url} ->
        search_contact_success_response()

      %{method: :put, url: ^update_contact_url} ->
        update_contact_success_response()
    end)
  end

  def mock_zoho_api(_), do: :ok
end
