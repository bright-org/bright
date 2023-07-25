defmodule BrightWeb.Admin.SkillCategoryLive.Show do
  use BrightWeb, :live_view

  alias Bright.SkillUnits

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    skill_category =
      SkillUnits.get_skill_category!(id)
      |> Bright.Repo.preload(:skills)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:skill_category, skill_category)}
  end

  defp page_title(:edit), do: "Edit Skill category"
end
