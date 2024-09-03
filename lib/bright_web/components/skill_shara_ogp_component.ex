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
      <div id="skill_shara_og_image" class="min-h-[630px] min-w-[1200px] content-center">
        <div class="flex flex-col gap-y-1 m-auto w-[350px]">
          <div><%= @skill_panel.name %></div>
          <div>クラス<%=@skill_class.class%>：<%=@skill_class.name%></div>
          <div class="mt-4">
            <.triangle_graph data={@data} id="ogp_triangle_graph"/>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
