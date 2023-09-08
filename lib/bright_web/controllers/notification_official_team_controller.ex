defmodule BrightWeb.NotificationOfficialTeamController do
  use BrightWeb, :controller

  alias Bright.Notifications
  alias Bright.Notifications.NotificationOfficialTeam

  action_fallback BrightWeb.FallbackController

  def index(conn, _params) do
    notification_official_teams = Notifications.list_notification_official_teams()
    render(conn, :index, notification_official_teams: notification_official_teams)
  end

  def create(conn, %{"notification_official_team" => notification_official_team_params}) do
    with {:ok, %NotificationOfficialTeam{} = notification_official_team} <-
           Notifications.create_notification_official_team(notification_official_team_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/notification_official_teams/#{notification_official_team}"
      )
      |> render(:show, notification_official_team: notification_official_team)
    end
  end

  def show(conn, %{"id" => id}) do
    notification_official_team = Notifications.get_notification_official_team!(id)
    render(conn, :show, notification_official_team: notification_official_team)
  end

  def update(conn, %{
        "id" => id,
        "notification_official_team" => notification_official_team_params
      }) do
    notification_official_team = Notifications.get_notification_official_team!(id)

    with {:ok, %NotificationOfficialTeam{} = notification_official_team} <-
           Notifications.update_notification_official_team(
             notification_official_team,
             notification_official_team_params
           ) do
      render(conn, :show, notification_official_team: notification_official_team)
    end
  end

  def delete(conn, %{"id" => id}) do
    notification_official_team = Notifications.get_notification_official_team!(id)

    with {:ok, %NotificationOfficialTeam{}} <-
           Notifications.delete_notification_official_team(notification_official_team) do
      send_resp(conn, :no_content, "")
    end
  end
end
