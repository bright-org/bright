defmodule BrightWeb.NotificationOfficialTeamJSON do
  alias Bright.Notifications.NotificationOfficialTeam

  @doc """
  Renders a list of notification_official_teams.
  """
  def index(%{notification_official_teams: notification_official_teams}) do
    %{
      data:
        for(
          notification_official_team <- notification_official_teams,
          do: data(notification_official_team)
        )
    }
  end

  @doc """
  Renders a single notification_official_team.
  """
  def show(%{notification_official_team: notification_official_team}) do
    %{data: data(notification_official_team)}
  end

  defp data(%NotificationOfficialTeam{} = notification_official_team) do
    %{
      id: notification_official_team.id,
      from_user_id: notification_official_team.from_user_id,
      to_user_id: notification_official_team.to_user_id,
      message: notification_official_team.message,
      detail: notification_official_team.detail,
      participation: notification_official_team.participation
    }
  end
end
