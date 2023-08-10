defmodule BrightWeb.ChartLive.SkillGemComponent do
  @moduledoc """
  Skill Gem Component
  """
  use BrightWeb, :live_component
  import BrightWeb.ChartComponents
  alias Bright.SkillScores

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-[450px] mx-auto my-12">
      <.skill_gem
        data={@skill_gem_data}
        id={@id}
        labels={@skill_gem_labels}/>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    skill_gem = SkillScores.get_skill_gem(assigns.user_id, assigns.skill_panel_id, assigns.class)
    skill_gem_data = [skill_gem |> Enum.map(fn x -> x.percentage end)]
    skill_gem_labels = skill_gem |> Enum.map(fn x -> x.name end)

    socket =
      socket
      |> assign(:skill_gem_data, skill_gem_data)
      |> assign(:skill_gem_labels, skill_gem_labels)

    {:ok, socket}
  end
end
