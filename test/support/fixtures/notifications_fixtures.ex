defmodule Bright.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Notifications` context.
  """

  @doc """
  Generate a notification.
  """
  def notification_fixture(attrs \\ %{}) do
    {:ok, notification} =
      attrs
      |> Enum.into(%{
        message: "some message",
        type: "some type",
        url: "some url",
        from_user_id: "7488a646-e31f-11e4-aace-600308960662",
        to_user_id: "7488a646-e31f-11e4-aace-600308960662",
        icon_type: "some icon_type",
        read_at: ~N[2023-07-07 10:08:00]
      })
      |> Bright.Notifications.create_notification()

    notification
  end
end
