defmodule Bright.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Notifications` context.
  """

  @doc """
  Generate a notification_official_team.
  """
  def notification_official_team_fixture(attrs \\ %{}) do
    {:ok, notification_official_team} =
      attrs
      |> Enum.into(%{
        message: "some message",
        detail: "some detail",
        from_user_id: "7488a646-e31f-11e4-aace-600308960662",
        to_user_id: "7488a646-e31f-11e4-aace-600308960662",
        participation: true
      })
      |> Bright.Notifications.create_notification_official_team()

    notification_official_team
  end
end
