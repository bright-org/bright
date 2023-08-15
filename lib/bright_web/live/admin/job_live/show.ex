defmodule BrightWeb.Admin.JobLive.Show do
  use BrightWeb, :live_view

  alias Bright.{Jobs, Repo}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:job, Jobs.get_job!(id) |> Repo.preload([:career_fields, :skill_panels]))}
  end

  defp page_title(:show), do: "Show Job"
  defp page_title(:edit), do: "Edit Job"
end
