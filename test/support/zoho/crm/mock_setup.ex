defmodule Bright.Zoho.Crm.MockSetup do
  @moduledoc """
  Zoho CRM API のモックをセットアップする

  use Bright.Zoho.Crm.MockSetup

  @tag zoho_crm_mock: :create_contact_success
  test "xxx" do
    xxx
  end
  """

  use ExUnit.Callbacks

  defmacro __using__(_opts) do
    quote do
      import Bright.Zoho.Crm.MockSetup
      setup :mock_crm_setup
    end
  end

  def mock_crm_setup(%{zoho_crm_mock: :create_contact_success}) do
    Tesla.Mock.mock(fn
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

  def mock_crm_setup(%{zoho_crm_mock: :create_contact_failure}) do
    Tesla.Mock.mock(fn
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

  def mock_crm_setup(%{zoho_crm_mock: :create_contact_connection_refused}) do
    Tesla.Mock.mock(fn
      %{method: :post, url: "https://www.zohoapis.jp/crm/v6/Contacts"} ->
        {:error, :econnrefused}
    end)
  end

  def mock_crm_setup(_), do: :ok
end
