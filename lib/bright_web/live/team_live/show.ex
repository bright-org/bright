defmodule BrightWeb.TeamLive.Show do
  use BrightWeb, :live_view

  alias Bright.Teams

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :bright_users, Users.list_bright_users())}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    team = Teams.get_team!(id)
    bright_users = team.
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:team, team)}
     |> assign(:bright_users, Teams.get_team!(id))}
  end

  defp page_title(:show), do: "Show Team"
  defp page_title(:edit), do: "Edit Team"
end
