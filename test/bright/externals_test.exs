defmodule Bright.ExternalsTest do
  use Bright.DataCase

  alias Bright.Externals
  alias Bright.Externals.ExternalToken

  describe "get_external_token/1" do
    test "returns the external_tokens with given type" do
      external_token = insert(:external_token, token_type: :ZOHO_CRM)
      assert Externals.get_external_token(%{token_type: :ZOHO_CRM}) == external_token
    end

    test "returns nil when no external_tokens with given type" do
      assert Externals.get_external_token(%{token_type: :ZOHO_CRM}) == nil
    end
  end

  describe "create_external_token/1" do
    @valid_attrs %{
      token: "some token",
      token_type: :ZOHO_CRM,
      api_domain: "some api_domain",
      expired_at: ~N[2024-08-06 15:38:00]
    }

    test "creates with valid data" do
      assert {:ok, %ExternalToken{} = external_token} =
               Externals.create_external_token(@valid_attrs)

      assert external_token.token == @valid_attrs[:token]
      assert external_token.token_type == @valid_attrs[:token_type]
      assert external_token.api_domain == @valid_attrs[:api_domain]
      assert external_token.expired_at == @valid_attrs[:expired_at]
    end

    test "returns error when invalid data" do
      assert {:error, %Ecto.Changeset{}} = Externals.create_external_token(%{})
    end

    test "returns error when invalid token_type" do
      assert {:error, %Ecto.Changeset{}} =
               @valid_attrs |> Map.put(:token_type, :INVALID) |> Externals.create_external_token()
    end
  end

  describe "update_external_token/2" do
    test "updates with valid data" do
      external_token = insert(:external_token)

      assert {:ok, %ExternalToken{} = external_token} =
               Externals.update_external_token(external_token, @valid_attrs)

      assert external_token.token == @valid_attrs[:token]
      assert external_token.token_type == @valid_attrs[:token_type]
      assert external_token.api_domain == @valid_attrs[:api_domain]
      assert external_token.expired_at == @valid_attrs[:expired_at]
    end

    test "returns error when invalid data" do
      external_token = insert(:external_token)

      assert {:error, %Ecto.Changeset{}} =
               Externals.update_external_token(
                 external_token,
                 @valid_attrs |> Map.put(:token_type, :INVALID)
               )
    end
  end

  describe "expired?/2" do
    test "returns true when expired" do
      external_token =
        insert(:external_token,
          expired_at: NaiveDateTime.utc_now() |> NaiveDateTime.add(-1, :second)
        )

      assert Externals.expired?(external_token, 0)
    end

    test "returns true when expired with default expiry_margin_sec 300s" do
      external_token =
        insert(:external_token,
          expired_at: NaiveDateTime.utc_now() |> NaiveDateTime.add(295, :second)
        )

      assert Externals.expired?(external_token)
    end

    test "returns false when not expired" do
      external_token =
        insert(:external_token,
          expired_at: NaiveDateTime.utc_now() |> NaiveDateTime.add(5, :second)
        )

      refute Externals.expired?(external_token, 0)
    end

    test "returns false when not expired with default expiry_margin_sec 300s" do
      external_token =
        insert(:external_token,
          expired_at: NaiveDateTime.utc_now() |> NaiveDateTime.add(305, :second)
        )

      refute Externals.expired?(external_token)
    end
  end
end
