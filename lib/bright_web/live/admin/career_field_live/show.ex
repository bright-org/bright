defmodule BrightWeb.Admin.CareerFieldLive.Show do
  use BrightWeb, :live_view

  alias Bright.Jobs

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:career_field, Jobs.get_career_field!(id))}
  end

  defp page_title(:show), do: "Show Career field"
  defp page_title(:edit), do: "Edit Career field"
end
