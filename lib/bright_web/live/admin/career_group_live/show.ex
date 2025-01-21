defmodule BrightWeb.Admin.CareerGroupLive.Show do
  use BrightWeb, :live_view

  alias Bright.CareerGroups
  alias Bright.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:career_group, CareerGroups.get_career_group!(id) |> Repo.preload(:career_fields))}
  end

  defp page_title(:show), do: "Show Career group"
  defp page_title(:edit), do: "Edit Career group"
end
