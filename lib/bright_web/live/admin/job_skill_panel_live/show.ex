defmodule BrightWeb.Admin.JobSkillPanelLive.Show do
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
     |> assign(:job_skill_panel, Jobs.get_job_skill_panel!(id))}
  end

  defp page_title(:show), do: "Show Job skill panel"
  defp page_title(:edit), do: "Edit Job skill panel"
end
