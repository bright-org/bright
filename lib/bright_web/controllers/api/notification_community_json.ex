defmodule BrightWeb.Api.NotificationCommunityJSON do
  alias Bright.Notifications.NotificationCommunity

  @doc """
  Renders a list of notification_communities.
  """
  def index(%{notification_communities: notification_communities}) do
    %{
      data:
        for(notification_community <- notification_communities, do: data(notification_community))
    }
  end

  @doc """
  Renders a single notification_community.
  """
  def show(%{notification_community: notification_community}) do
    %{data: data(notification_community)}
  end

  defp data(%NotificationCommunity{} = notification_community) do
    %{
      id: notification_community.id,
      from_user_id: notification_community.from_user_id,
      message: notification_community.message,
      detail: notification_community.detail
    }
  end
end
