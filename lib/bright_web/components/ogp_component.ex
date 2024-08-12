defmodule BrightWeb.OgpComponent do
  @moduledoc """
  Ogp Component
  """
  use BrightWeb, :live_component

  import BrightWeb.SkillPanelLive.SkillPanelComponents,
    only: [profile_skill_class_level: 1]

  def render(assigns) do
    ~H"""
     <div class="absolute flow -left-[1200px] w-[1200px]">
      <p class="hidden" id="og_image_data" phx-click="og_image_data_click" />
      <div id="og_image" class="pt-5 px-80 min-h-[630px]">
        <div class="flex justify-center">
          <div class="flex flex-col gap-y-2 font-bold justify-center">
            <span class="truncate w-80 h-10 text-lg"> <%= if @skill_panel, do: @skill_panel.name, else: "" %></span>
            <div class="flex flex-row gap-x-4 gap-y-2 lgap-y-0">
              <span class="text-normal w-14">クラス<%= if @skill_class, do: @skill_class.class, else: "" %></span>
              <span class="text-normal w-[360px] break-all"><%= if @skill_class, do: @skill_class.name, else: ""  %></span>
            </div>
            <p class="text-brightGreen-300 font-bold flextext-brightGreen-300 font-bold flex ml-[7px] mt-2 ml-4 mb-8">
              <.profile_skill_class_level level={@skill_class_score.level} />
            </p>
          </div>
        </div>
        <div class="min-h-[450px] flex justify-center">
          <.live_component
            id="skill-ogp-gem"
            module={BrightWeb.ChartLive.SkillGemComponent}
            display_user={@display_user}
            skill_panel={@skill_panel}
            class={@skill_class.class}
            select_label={@select_label}
            me={@me}
            anonymous={@anonymous}
            select_label_compared_user={@select_label_compared_user}
            compared_user={@compared_user}
            updated_gem_dt={@updated_gem_dt}
          />
        </div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(updated_gem_dt: DateTime.utc_now())

    {:ok, socket}
  end
end
