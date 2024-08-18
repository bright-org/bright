defmodule Bright.Zoho.CrmTest do
  use Bright.DataCase
  use Bright.Zoho.MockSetup

  import ExUnit.CaptureLog

  alias Bright.Externals
  alias Bright.Zoho.Crm

  describe "create_contact/1" do
    @tag zoho_mock: :create_contact_success
    test "creates contact when no external_tokens record" do
      assert {:ok, %Tesla.Env{status: 201}} =
               Crm.build_create_contact_payload(%{name: "test", email: "email"})
               |> Crm.create_contact()

      new_token = Externals.get_external_token(%{token_type: :ZOHO_CRM})
      assert new_token.token == "new_token"
      assert new_token.token_type == :ZOHO_CRM
      refute new_token |> Externals.token_expired?()
    end

    @tag zoho_mock: :create_contact_success_without_token_request
    test "creates contact when external_tokens record exists" do
      insert(:external_token,
        token: "unexpired_token",
        token_type: :ZOHO_CRM,
        api_domain: "https://www.zohoapis.jp",
        expired_at: DateTime.utc_now() |> DateTime.add(3600, :second)
      )

      assert {:ok, %Tesla.Env{status: 201}} =
               Crm.build_create_contact_payload(%{name: "test", email: "email"})
               |> Crm.create_contact()

      new_token = Externals.get_external_token(%{token_type: :ZOHO_CRM})
      assert new_token.token == "unexpired_token"
    end

    @tag zoho_mock: :create_contact_success
    test "creates contact when external_tokens record exists but expired" do
      insert(:external_token,
        token: "expired_token",
        token_type: :ZOHO_CRM,
        api_domain: "https://www.zohoapis.jp",
        expired_at: DateTime.utc_now()
      )

      assert {:ok, %Tesla.Env{status: 201}} =
               Crm.build_create_contact_payload(%{name: "test", email: "email"})
               |> Crm.create_contact()

      new_token = Externals.get_external_token(%{token_type: :ZOHO_CRM})
      assert new_token.token == "new_token"
      assert new_token.token_type == :ZOHO_CRM
      refute new_token |> Externals.token_expired?()
    end

    @tag zoho_mock: :auth_failure
    test "returns error when auth failure" do
      log =
        capture_log(fn ->
          assert :error =
                   Crm.build_create_contact_payload(%{name: "test", email: "email"})
                   |> Crm.create_contact()
        end)

      assert log =~ "Failed to Zoho Auth: invalid_client"
    end

    @tag zoho_mock: :auth_connection_refused
    test "returns error when auth connection refused" do
      log =
        capture_log(fn ->
          assert :error =
                   Crm.build_create_contact_payload(%{name: "test", email: "email"})
                   |> Crm.create_contact()
        end)

      assert log =~ "Failed to Zoho Auth: :econnrefused"
    end

    @tag zoho_mock: :auth_server_error
    test "returns error when auth server error" do
      log =
        capture_log(fn ->
          assert :error =
                   Crm.build_create_contact_payload(%{name: "test", email: "email"})
                   |> Crm.create_contact()
        end)

      assert log =~ "Failed to Zoho Auth:"
    end

    @tag zoho_mock: :create_contact_failure
    test "returns error when create contact failure" do
      log =
        capture_log(fn ->
          assert :error =
                   Crm.build_create_contact_payload(%{name: "test", email: "email"})
                   |> Crm.create_contact()
        end)

      assert log =~ "Failed to create_contact:"
    end

    @tag zoho_mock: :create_contact_connection_refused
    test "returns error when create contact connection refused" do
      log =
        capture_log(fn ->
          assert :error =
                   Crm.build_create_contact_payload(%{name: "test", email: "email"})
                   |> Crm.create_contact()
        end)

      assert log =~ "Failed to create_contact: :econnrefused"
    end
  end

  describe "build_create_contact_payload/1" do
    test "builds payload" do
      assert %{
               "data" => [%{"Email" => "email", "Last_Name" => "test", "field9" => "Brightユーザー"}]
             } =
               Crm.build_create_contact_payload(%{name: "test", email: "email"})
    end
  end
end
