defmodule Bright.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Accounts` context.
  """

  @doc """
  Generate a user2fa_codes.
  """
  def user2fa_codes_fixture(attrs \\ %{}) do
    {:ok, user2fa_codes} =
      attrs
      |> Enum.into(%{
        code: "some code",
        sent_to: "some sent_to"
      })
      |> Bright.Accounts.create_user2fa_codes()

    user2fa_codes
  end
end
