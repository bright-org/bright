defmodule BrightWeb.SkillSharaOgpComponent do
  @moduledoc """
  Skill shara ogp Component
  """
  use BrightWeb, :live_component
  import BrightWeb.BrightGraphComponents

  def render(assigns) do
    ~H"""
     <div class="absolute flow -left-[1200px] w-[1200px]">
      <p class="hidden" id="skill_shara_og_image_data" phx-click="skill_shara_og_image_data_click" />
      <div id="skill_shara_og_image" class="pt-5 px-80 min-h-[630px]">
      <.triangle_graph data={@data} id="ogp_triangle_graph"/>
      </div>
    </div>
    """
  end
end
