defmodule Bright.Zoho.AuthTest do
  use ExUnit.Case, async: true
  use Bright.Zoho.MockAuthSetup

  alias Bright.Zoho.Auth

  describe "new/1" do
    test "returns a Tesla client" do
      assert %Tesla.Client{} = Auth.new()
    end
  end

  describe "auth/1" do
    @tag zoho_auth_mock: :auth_success
    test "returns a Tesla.Env" do
      assert {:ok,
              %Tesla.Env{
                body: %{
                  "access_token" => "xxxxx",
                  "expires_in" => 3600,
                  "api_domain" => "https://www.zohoapis.jp"
                }
              }} = Auth.new() |> Auth.auth()
    end

    @tag zoho_auth_mock: :auth_failure
    test "returns an error" do
      assert {:ok, %Tesla.Env{body: %{"error" => "invalid_client"}}} = Auth.new() |> Auth.auth()
    end

    @tag zoho_auth_mock: :auth_connection_refused
    test "returns an :econnrefused error" do
      assert {:error, :econnrefused} = Auth.new() |> Auth.auth()
    end
  end
end
