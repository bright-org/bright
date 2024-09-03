defmodule Bright.Zoho.Crm.ClientTest do
  use ExUnit.Case, async: true
  use Bright.Zoho.MockSetup

  alias Bright.Zoho.Crm.Client

  describe "new/1" do
    test "returns a Tesla client" do
      assert %Tesla.Client{} =
               Client.new(%{api_domain: "https://www.zohoapis.jp", access_token: "xxxxx"})
    end
  end

  describe "create_record/2" do
    @tag zoho_mock: :create_contact_success
    test "returns status 201" do
      assert {:ok, %Tesla.Env{status: 201}} =
               Client.new(%{api_domain: "https://www.zohoapis.jp", access_token: "xxxxx"})
               |> Client.create_contact(%{
                 "data" => [
                   %{
                     "Last_Name" => "test",
                     "Email" => "test@example.com",
                     "field_9" => "Brightユーザー"
                   }
                 ]
               })
    end

    @tag zoho_mock: :create_contact_failure
    test "returns a status 400" do
      assert {:ok, %Tesla.Env{status: 400}} =
               Client.new(%{api_domain: "https://www.zohoapis.jp", access_token: "xxxxx"})
               |> Client.create_contact(%{"data" => []})
    end

    @tag zoho_mock: :create_contact_connection_refused
    test "returns a connection refused error" do
      assert {:error, :econnrefused} =
               Client.new(%{api_domain: "https://www.zohoapis.jp", access_token: "xxxxx"})
               |> Client.create_contact(%{
                 "data" => [
                   %{
                     "Last_Name" => "test",
                     "Email" => "test@example.com",
                     "field_9" => "Brightユーザー"
                   }
                 ]
               })
    end
  end

  describe "search_contact_by_email/2" do
    @tag zoho_mock: {:search_contact_by_email_success, "hoge@example.com"}
    test "returns status 200" do
      assert {:ok, %Tesla.Env{status: 200, body: %{"data" => data}}} =
               Client.new(%{api_domain: "https://www.zohoapis.jp", access_token: "xxxxx"})
               |> Client.search_contact_by_email("hoge@example.com")

      assert is_list(data)
    end

    @tag zoho_mock: {:search_contact_missing, "hoge@example.com"}
    test "returns status 204" do
      assert {:ok, %Tesla.Env{status: 204, body: _body}} =
               Client.new(%{api_domain: "https://www.zohoapis.jp", access_token: "xxxxx"})
               |> Client.search_contact_by_email("hoge@example.com")
    end

    @tag zoho_mock: {:search_contact_failure, "hoge@example.com"}
    test "returns status 400" do
      assert {:ok, %Tesla.Env{status: 400, body: _body}} =
               Client.new(%{api_domain: "https://www.zohoapis.jp", access_token: "xxxxx"})
               |> Client.search_contact_by_email("hoge@example.com")
    end

    @tag zoho_mock: {:search_contact_connection_refused, "hoge@example.com"}
    test "returns a connection refused error" do
      assert {:error, :econnrefused} =
               Client.new(%{api_domain: "https://www.zohoapis.jp", access_token: "xxxxx"})
               |> Client.search_contact_by_email("hoge@example.com")
    end
  end

  describe "update_contact/2" do
    @tag zoho_mock: {:update_contact_success, "100"}
    test "returns status 200" do
      assert {:ok, %Tesla.Env{status: 200}} =
               Client.new(%{api_domain: "https://www.zohoapis.jp", access_token: "xxxxx"})
               |> Client.update_contact("100", %{
                 "data" => [%{"Last_Name" => "test", "Email" => "test@example.com"}]
               })
    end

    @tag zoho_mock: {:update_contact_failure, "100"}
    test "returns status 400" do
      assert {:ok, %Tesla.Env{status: 400}} =
               Client.new(%{api_domain: "https://www.zohoapis.jp", access_token: "xxxxx"})
               |> Client.update_contact("100", %{
                 "data" => [%{"Last_Name" => "test", "Email" => "test@example.com"}]
               })
    end

    @tag zoho_mock: {:update_contact_connection_refused, "100"}
    test "returns a connection refused error" do
      assert {:error, :econnrefused} =
               Client.new(%{api_domain: "https://www.zohoapis.jp", access_token: "xxxxx"})
               |> Client.update_contact("100", %{
                 "data" => [%{"Last_Name" => "test", "Email" => "test@example.com"}]
               })
    end
  end
end
