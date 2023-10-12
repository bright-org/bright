defmodule BrightWeb.Api.NotificationCommunityController do
  use BrightWeb, :controller

  alias Bright.NotificationCommunities
  alias Bright.Notifications.NotificationCommunity

  action_fallback BrightWeb.FallbackController

  def index(conn, _params) do
    notification_communities = NotificationCommunities.list_notification_communities()
    render(conn, :index, notification_communities: notification_communities)
  end

  def create(conn, %{"notification_community" => notification_community_params}) do
    with {:ok, %NotificationCommunity{} = notification_community} <-
           NotificationCommunities.create_notification_community(notification_community_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/v1/notification_communities/#{notification_community}"
      )
      |> render(:show, notification_community: notification_community)
    end
  end

  def show(conn, %{"id" => id}) do
    notification_community = NotificationCommunities.get_notification_community!(id)
    render(conn, :show, notification_community: notification_community)
  end

  def update(conn, %{"id" => id, "notification_community" => notification_community_params}) do
    notification_community = NotificationCommunities.get_notification_community!(id)

    with {:ok, %NotificationCommunity{} = notification_community} <-
           NotificationCommunities.update_notification_community(
             notification_community,
             notification_community_params
           ) do
      render(conn, :show, notification_community: notification_community)
    end
  end

  def delete(conn, %{"id" => id}) do
    notification_community = NotificationCommunities.get_notification_community!(id)

    with {:ok, %NotificationCommunity{}} <-
           NotificationCommunities.delete_notification_community(notification_community) do
      send_resp(conn, :no_content, "")
    end
  end
end
