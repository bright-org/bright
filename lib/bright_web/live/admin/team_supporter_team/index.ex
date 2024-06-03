defmodule BrightWeb.Admin.TeamSupporterTeamLive.Index do
  use BrightWeb, :live_view

  alias Bright.Teams
  alias Bright.Teams.TeamSupporterTeam

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(
       socket,
       :team_supporter_teams,
       list_team_supporter_teams()
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Team Supporter Team")
    |> assign(:team_supporter_team, Teams.get_team_supporter_team!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Team Supporter Team")
    |> assign(:team_supporter_team, %TeamSupporterTeam{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Team Supporter Team")
    |> assign(:team_supporter_team, nil)
  end

  @impl true
  def handle_info(
        {BrightWeb.Admin.TeamSupporterTeamLive.FormComponent, {:saved, team}},
        socket
      ) do
    team = Teams.get_team_supporter_team!(team.id)
    {:noreply, stream_insert(socket, :team_supporter_teams, team, at: 0)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    team = Teams.get_team_supporter_team!(id)
    {:ok, _} = Teams.delete_team_supporter_team(team)

    {:noreply, stream_delete(socket, :team_supporter_teams, team)}
  end

  defp list_team_supporter_teams do
    Teams.list_team_supporter_team()
    |> Enum.sort_by(& &1.updated_at, {:desc, NaiveDateTime})
  end
end
