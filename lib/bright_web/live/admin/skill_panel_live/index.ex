defmodule BrightWeb.Admin.SkillPanelLive.Index do
  use BrightWeb, :live_view

  alias Bright.Repo
  alias Bright.SkillPanels
  alias Bright.SkillPanels.SkillPanel

  @impl true
  def mount(_params, _session, socket) do
    skill_panels = SkillPanels.list_skill_panels() |> Repo.preload(:career_field)
    {:ok, stream(socket, :skill_panels, skill_panels)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Skill panel")
    |> assign(:skill_panel, SkillPanels.get_skill_panel!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Skill panel")
    |> assign(:skill_panel, %SkillPanel{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Skill panels")
    |> assign(:skill_panel, nil)
  end

  @impl true
  def handle_info({BrightWeb.Admin.SkillPanelLive.FormComponent, {:saved, skill_panel}}, socket) do
    {:noreply, stream_insert(socket, :skill_panels, skill_panel)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    skill_panel = SkillPanels.get_skill_panel!(id)
    {:ok, _} = SkillPanels.delete_skill_panel(skill_panel)

    {:noreply, stream_delete(socket, :skill_panels, skill_panel)}
  end
end
