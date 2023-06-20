defmodule BrightWeb.UserJoinedTeamLive.Index do
  use BrightWeb, :live_view

  alias Bright.Teams
  alias Bright.Teams.UserJoinedTeam

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :user_joined_teams, Teams.list_user_joined_teams())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User joined team")
    |> assign(:user_joined_team, Teams.get_user_joined_team!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User joined team")
    |> assign(:user_joined_team, %UserJoinedTeam{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing User joined teams")
    |> assign(:user_joined_team, nil)
  end

  @impl true
  def handle_info({BrightWeb.UserJoinedTeamLive.FormComponent, {:saved, user_joined_team}}, socket) do
    {:noreply, stream_insert(socket, :user_joined_teams, user_joined_team)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_joined_team = Teams.get_user_joined_team!(id)
    {:ok, _} = Teams.delete_user_joined_team(user_joined_team)

    {:noreply, stream_delete(socket, :user_joined_teams, user_joined_team)}
  end
end
