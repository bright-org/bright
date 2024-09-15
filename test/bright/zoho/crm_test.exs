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

  describe "get_contacts_by_email/1" do
    @tag zoho_mock: {:search_contact_by_email_success, "hoge@example.com"}
    test "gets contact successfully" do
      assert {:ok,
              [
                %{
                  "id" => "100",
                  "Last_Name" => "koyo2"
                }
              ]} =
               Crm.get_contacts_by_email("hoge@example.com")
    end

    @tag zoho_mock: {:search_contact_missing, "hoge@example.com"}
    test "gets contact with no data" do
      assert {:ok, []} = Crm.get_contacts_by_email("hoge@example.com")
    end

    @tag zoho_mock: {:search_contact_failure, "hoge@example.com"}
    test "gets contact failure with invalid error" do
      log =
        capture_log(fn ->
          assert :error = Crm.get_contacts_by_email("hoge@example.com")
        end)

      assert log =~ "Failed to get_contacts_by_email:"
    end

    @tag zoho_mock: {:search_contact_connection_refused, "hoge@example.com"}
    test "gets contact failure with connection error" do
      log =
        capture_log(fn ->
          assert :error = Crm.get_contacts_by_email("hoge@example.com")
        end)

      assert log =~ "Failed to get_contacts_by_email:"
    end

    @tag zoho_mock: :auth_failure
    test "returns error when auth failure" do
      log =
        capture_log(fn ->
          assert :error = Crm.get_contacts_by_email(%{name: "test", email: "email"})
        end)

      assert log =~ "Failed to Zoho Auth: invalid_client"
    end
  end

  describe "update_contact/2" do
    @tag zoho_mock: {:update_contact_success, "100"}
    test "updates contact" do
      assert {:ok, %Tesla.Env{status: 200}} =
               Crm.build_update_contact_payload(%{name: "test", email: "email"})
               |> then(&Crm.update_contact("100", &1))
    end

    @tag zoho_mock: {:update_contact_failure, "100"}
    test "returns error when update contact failure" do
      log =
        capture_log(fn ->
          assert :error =
                   Crm.build_update_contact_payload(%{name: "test", email: "email"})
                   |> then(&Crm.update_contact("100", &1))
        end)

      assert log =~ "Failed to update_contact:"
    end

    @tag zoho_mock: {:update_contact_connection_refused, "100"}
    test "returns error when update contact connection refused" do
      log =
        capture_log(fn ->
          assert :error =
                   Crm.build_update_contact_payload(%{name: "test", email: "email"})
                   |> then(&Crm.update_contact("100", &1))
        end)

      assert log =~ "Failed to update_contact: :econnrefused"
    end

    @tag zoho_mock: :auth_failure
    test "returns error when auth failure" do
      log =
        capture_log(fn ->
          assert :error =
                   Crm.build_update_contact_payload(%{name: "test", email: "email"})
                   |> then(&Crm.update_contact("100", &1))
        end)

      assert log =~ "Failed to Zoho Auth: invalid_client"
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

  describe "build_update_contact_payload/1" do
    test "builds payload" do
      assert %{
               "data" => [%{"Email" => "email", "Last_Name" => "test"}]
             } =
               Crm.build_update_contact_payload(%{name: "test", email: "email"})
    end
  end
end
