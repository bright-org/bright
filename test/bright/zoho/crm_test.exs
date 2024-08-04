defmodule Bright.Zoho.CrmTest do
  use Bright.DataCase
  use Bright.Zoho.MockSetup

  import ExUnit.CaptureLog

  alias Bright.Zoho.Crm

  describe "create_contact/1" do
    @tag zoho_mock: :create_contact_success
    test "creates contact" do
      assert {:ok, %Tesla.Env{status: 201}} =
               Crm.build_create_contact_payload(%{name: "test", email: "email"})
               |> Crm.create_contact()
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
      assert %{"data" => [%{"Email" => "email", "Last_Name" => "test"}]} =
               Crm.build_create_contact_payload(%{name: "test", email: "email"})
    end
  end
end
