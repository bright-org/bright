defmodule Bright.ExternalsTest do
  use Bright.DataCase

  alias Bright.Externals

  describe "external_tokens" do
    alias Bright.Externals.ExternalTokens

    import Bright.ExternalsFixtures

    @invalid_attrs %{token: nil, token_type: nil, api_domain: nil, expired_at: nil}

    test "list_external_tokens/0 returns all external_tokens" do
      external_tokens = external_tokens_fixture()
      assert Externals.list_external_tokens() == [external_tokens]
    end

    test "get_external_tokens!/1 returns the external_tokens with given id" do
      external_tokens = external_tokens_fixture()
      assert Externals.get_external_tokens!(external_tokens.id) == external_tokens
    end

    test "create_external_tokens/1 with valid data creates a external_tokens" do
      valid_attrs = %{token: "some token", token_type: "some token_type", api_domain: "some api_domain", expired_at: ~N[2024-08-06 15:38:00]}

      assert {:ok, %ExternalTokens{} = external_tokens} = Externals.create_external_tokens(valid_attrs)
      assert external_tokens.token == "some token"
      assert external_tokens.token_type == "some token_type"
      assert external_tokens.api_domain == "some api_domain"
      assert external_tokens.expired_at == ~N[2024-08-06 15:38:00]
    end

    test "create_external_tokens/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Externals.create_external_tokens(@invalid_attrs)
    end

    test "update_external_tokens/2 with valid data updates the external_tokens" do
      external_tokens = external_tokens_fixture()
      update_attrs = %{token: "some updated token", token_type: "some updated token_type", api_domain: "some updated api_domain", expired_at: ~N[2024-08-07 15:38:00]}

      assert {:ok, %ExternalTokens{} = external_tokens} = Externals.update_external_tokens(external_tokens, update_attrs)
      assert external_tokens.token == "some updated token"
      assert external_tokens.token_type == "some updated token_type"
      assert external_tokens.api_domain == "some updated api_domain"
      assert external_tokens.expired_at == ~N[2024-08-07 15:38:00]
    end

    test "update_external_tokens/2 with invalid data returns error changeset" do
      external_tokens = external_tokens_fixture()
      assert {:error, %Ecto.Changeset{}} = Externals.update_external_tokens(external_tokens, @invalid_attrs)
      assert external_tokens == Externals.get_external_tokens!(external_tokens.id)
    end

    test "delete_external_tokens/1 deletes the external_tokens" do
      external_tokens = external_tokens_fixture()
      assert {:ok, %ExternalTokens{}} = Externals.delete_external_tokens(external_tokens)
      assert_raise Ecto.NoResultsError, fn -> Externals.get_external_tokens!(external_tokens.id) end
    end

    test "change_external_tokens/1 returns a external_tokens changeset" do
      external_tokens = external_tokens_fixture()
      assert %Ecto.Changeset{} = Externals.change_external_tokens(external_tokens)
    end
  end
end
