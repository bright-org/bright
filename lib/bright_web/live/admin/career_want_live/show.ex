defmodule BrightWeb.Admin.CareerWantLive.Show do
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
     |> assign(:career_want, Jobs.get_career_want!(id))}
  end

  defp page_title(:show), do: "Show Career want"
  defp page_title(:edit), do: "Edit Career want"
end
