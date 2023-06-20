defmodule BrightWeb.UserJoinedTeamLive.Show do
  use BrightWeb, :live_view

  alias Bright.Teams

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user_joined_team, Teams.get_user_joined_team!(id))}
  end

  defp page_title(:show), do: "Show User joined team"
  defp page_title(:edit), do: "Edit User joined team"
end
