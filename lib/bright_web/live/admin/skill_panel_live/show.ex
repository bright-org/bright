defmodule BrightWeb.Admin.SkillPanelLive.Show do
  use BrightWeb, :live_view

  alias Bright.SkillPanels

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    skill_panel = SkillPanels.get_skill_panel!(id) |> Bright.Repo.preload(:skill_classes)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:skill_panel, skill_panel)}
  end

  defp page_title(:show), do: "Show Skill panel"
  defp page_title(:edit), do: "Edit Skill panel"
end
