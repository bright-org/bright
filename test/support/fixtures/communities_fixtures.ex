defmodule Bright.CommunitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Communities` context.
  """

  @doc """
  Generate a community.
  """
  def community_fixture(attrs \\ %{}) do
    {:ok, community} =
      attrs
      |> Enum.into(%{
        name: "some name",
        user_id: "7488a646-e31f-11e4-aace-600308960662",
        community_id: "7488a646-e31f-11e4-aace-600308960662",
        participation: true
      })
      |> Bright.Communities.create_community()

    community
  end
end
