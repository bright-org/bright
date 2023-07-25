defmodule BrightWeb.Admin.SkillLive.Show do
  use BrightWeb, :live_view

  alias Bright.SkillUnits

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    skill =
      SkillUnits.get_skill!(id)
      |> Bright.Repo.preload(skill_category: [:skill_unit])

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:skill, skill)}
  end

  defp page_title(:edit), do: "Edit Skill"
end
