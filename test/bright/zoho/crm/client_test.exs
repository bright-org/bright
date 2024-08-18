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
                 "data" => [%{"Last_Name" => "test", "Email" => "test@example.com"}]
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
                 "data" => [%{"Last_Name" => "test", "Email" => "test@example.com"}]
               })
    end
  end
end
