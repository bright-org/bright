defmodule Bright.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Notifications` context.
  """

  @doc """
  Generate a notification_community.
  """
  def notification_community_fixture(attrs \\ %{}) do
    {:ok, notification_community} =
      attrs
      |> Enum.into(%{
        message: "some message",
        from_user_id: "7488a646-e31f-11e4-aace-600308960662",
        detail: "some detail"
      })
      |> Bright.Notifications.create_notification_community()

    notification_community
  end
end
