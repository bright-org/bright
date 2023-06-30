defmodule BrightWeb.Admin.SkillUnitLive.Index do
  use BrightWeb, :live_view

  alias Bright.SkillUnits
  alias Bright.SkillUnits.SkillUnit

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :skill_units, SkillUnits.list_skill_units())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Skill panel")
    |> assign(:skill_unit, SkillUnits.get_skill_unit!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Skill panel")
    |> assign(:skill_unit, %SkillUnit{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Skill panels")
    |> assign(:skill_unit, nil)
  end

  @impl true
  def handle_info({BrightWeb.Admin.SkillUnitLive.FormComponent, {:saved, skill_unit}}, socket) do
    {:noreply, stream_insert(socket, :skill_units, skill_unit)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    skill_unit = SkillUnits.get_skill_unit!(id)
    {:ok, _} = SkillUnits.delete_skill_unit(skill_unit)

    {:noreply, stream_delete(socket, :skill_units, skill_unit)}
  end
end
