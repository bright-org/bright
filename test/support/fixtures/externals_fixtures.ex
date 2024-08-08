defmodule Bright.ExternalsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Externals` context.
  """

  @doc """
  Generate a external_tokens.
  """
  def external_tokens_fixture(attrs \\ %{}) do
    {:ok, external_tokens} =
      attrs
      |> Enum.into(%{
        api_domain: "some api_domain",
        expired_at: ~N[2024-08-06 15:38:00],
        token: "some token",
        token_type: "some token_type"
      })
      |> Bright.Externals.create_external_tokens()

    external_tokens
  end
end
