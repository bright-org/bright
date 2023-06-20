defmodule BrightWeb.BrightUserLive.Show do
  use BrightWeb, :live_view

  alias Bright.Users

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:bright_user, Users.get_bright_user!(id))}
  end

  defp page_title(:show), do: "Show Bright user"
  defp page_title(:edit), do: "Edit Bright user"
end
