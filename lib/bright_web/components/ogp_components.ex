defmodule BrightWeb.OgpComponents do
  @moduledoc """
  Tab Components
  """
  use Phoenix.Component
  import BrightWeb.SkillPanelLive.SkillPanelComponents,
  only: [profile_skill_class_level: 1]

  @doc """
  Renders a Ogp

  ## Examples
    <BrightWeb.OgpComponents.ogp
      skill_panel={@skill_panel}
      skill_class={@skill_class}
      skill_class_score={@skill_class_score}
      display_user={@display_user}
      select_label={@select_label}
      me={@me}
      anonymous={@anonymous}
      select_label_compared_user={@select_label_compared_user}
      compared_user={@compared_user}
    />

  """

  attr :skill_panel, :any
  attr :skill_class, :any
  attr :skill_class_score, :any
  attr :display_user, :any
  attr :select_label, :any
  attr :me, :any
  attr :anonymous, :any
  attr :select_label_compared_user,:any
  attr :compared_user, :any

  def ogp(assigns) do
    ~H"""
    <div class="absolute flow -left-[1000px]">
      <div id="og_image" class="pl-4">
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
        <div class="min-h-[450px]">
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
          />
        </div>
      </div>
    </div>
    """
  end
end
