defmodule BrightWeb.Admin.SkillUnitLive.Show do
  use BrightWeb, :live_view

  alias Bright.SkillUnits

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    skill_unit =
      SkillUnits.get_skill_unit!(id)
      |> Bright.Repo.preload([:skill_categories, skill_classes: :skill_panel])

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:skill_unit, skill_unit)}
  end

  defp page_title(:show), do: "Show Skill unit"
  defp page_title(:edit), do: "Edit Skill unit"
end
