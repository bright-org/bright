defmodule BrightWeb.Admin.UserOnboardingsLive.Show do
  use BrightWeb, :live_view

  alias Bright.Onboardings

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user_onboardings, Onboardings.get_user_onboardings!(id))}
  end

  defp page_title(:show), do: "Show User onboardings"
  defp page_title(:edit), do: "Edit User onboardings"
end
