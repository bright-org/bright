defmodule BrightWeb.Admin.DraftSkillClassLive.Show do
  use BrightWeb, :live_view

  alias Bright.DraftSkillPanels

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    skill_class = DraftSkillPanels.get_draft_skill_class!(id)
    skill_panel = DraftSkillPanels.get_skill_panel!(skill_class.skill_panel_id)

    {:noreply,
     socket
     |> assign(:skill_panel, skill_panel)
     |> assign(:skill_class, skill_class)}
  end
end
