defmodule BrightWeb.SkillPanelLive.SkillCardComponents do
  use BrightWeb, :component

  import BrightWeb.MegaMenuComponents, only: [mega_menu_button: 1]

  import BrightWeb.SkillPanelLive.SkillPanelComponents,
    only: [profile_skill_class_level: 1, score_mark_class: 2]

  import BrightWeb.ChartComponents, only: [skill_gem: 1]

  alias Bright.SkillScores
  alias BrightWeb.SnsComponents
  alias BrightWeb.QrCodeComponents

  def switch_user(assigns) do
    ~H"""
    <.mega_menu_button
      id="related_user_card_menu"
      dropdown_offset_skidding="307"
      color="bg-white"
      divide={false}
    >
      <:button_content>
        <div class="flex">
          <img
            class="object-cover inline-block h-[28px] w-[28px] rounded-full mr-2"
            src={Bright.UserProfiles.icon_url(@display_user.user_profile.icon_file_path)}
          />
          <span class="mt-1"><%= @display_user.name%></span>
        </div>
        <div class="mt-1 mr-2"><.icon name="hero-chevron-down" /> </div>
      </:button_content>
      <.live_component
        id="related_user"
        module={BrightWeb.CardLive.RelatedUserCardComponent}
        current_user={@current_user}
        purpose="menu"
        without_me={false}
      />
    </.mega_menu_button>
    """
  end

  def switch_skill(assigns) do
    ~H"""
    <.mega_menu_button
      id="skill_card_menu"
      dropdown_offset_skidding="100"
      menu_width={"lg:w-[340px]"}
      color="bg-white"
      divide={false}
    >
      <:button_content>
        <div class="flex mr-4 my-1">
        <.icon name="hero-arrow-path" />
          スキル切替
        </div>
      </:button_content>
      <div class="mt-2">
      <.live_component
        id="skill_list"
        module={BrightWeb.SkillListComponent}
        display_user={@display_user}
        me={@me}
        root="more_skills"
        anonymous={@anonymous}
        career_field={nil}
        current_skill_class={@skill_class}
        per_page={10}
      />
      </div>
    </.mega_menu_button>
    """
  end

  def gem_area(assigns) do
    ~H"""
    <div class="bg-white rounded-lg flex flex-col py-8 h-full lg:h-[470px]">
      <div class="flex justify-center">
        <span class="bg-brightGreen-300 text-white py-[3px] px-2 rounded-lg mr-1">クラス<%= @skill_class.class %></span>
        <span class="font-bold"><%= @skill_class.name %></span>
      </div>
      <div class="flex flex-col lg:flex-row items-center justify-between mt-1 lg:px-4">
        <.prev_class skill_class={@skill_class} path={@path} query={@query} />
        <div class="flex justify-center flex-col">
          <div phx-click="scroll_to_unit">
            <.skill_gem
              id={"sk-#{@skill_class.id}"}
              labels={@gem_labels}
              data={[@gem_values]}
              size="base"
              links={@links}
              display_link="true"
            />
          </div>
          <div class="flex flex-col lg:flex-row px-2 lg:px-0 gap-x-2">
            <.skill_stat counter={@counter}  num_skills={@num_skills} />
            <div class="flex gap-x-2 items-end px-8 lg:px-0 -mt-8 lg:mt-0">
              <SnsComponents.sns_share_button_group share_graph_url={@share_graph_url} skill_panel={@skill_panel.name} direction="lg:flex-col lg:justify-between lg:h-[75px] lg:py-1" />
              <QrCodeComponents.qr_code_image class="border border-b-2 border-brightGray-200" qr_code_url={@share_graph_url} width="80px" height="80px" />
            </div>
          </div>
        </div>
        <.next_class skill_class={@skill_class} path={@path} query={@query}/>
      </div>
    </div>
    """
  end

  # 入力時間目安表示のための１スキルあたりの時間(分): 約20秒
  @minute_per_skill 0.33

  def skill_stat(assigns) do
    ~H"""
    <div class="flex flex-col px-9 lg:px-0 lg:mr-4 pt-2">
      <div class="flex gap-x-1">
        <div class="text-brightGreen-300 font-bold flex h-4">
          <.profile_skill_class_level level={get_level(@counter, @num_skills)} />
        </div>
        <div class="flex items-center justify-center">
          <span class={[score_mark_class(:high, :green), "inline-block mr-1"]}></span>
          <span class="score-high-percentage"><%= SkillScores.calc_high_skills_percentage(@counter.high, @num_skills) %>％</span>
        </div>
        <div class="flex items-center justify-center">
          <span class={[score_mark_class(:middle, :green), "inline-block mr-1"]}></span>
          <span class="score-middle-percentage"><%= SkillScores.calc_middle_skills_percentage(@counter.middle, @num_skills) %>％</span>
        </div>
      </div>
      <div class="flex flex-col">
        <div class="flex gap-x-2 lg:justify-between">
          <p class="text-xs font-bold">スキル数</p>
          <p class="text-sm text-right"><%= @num_skills %></p>
        </div>
        <div class="flex gap-x-2 lg:justify-between">
          <p class="text-xs font-bold">入力目安</p>
          <p class="text-sm text-right"><%= round(minute_per_skill() * @num_skills) %>分</p>
        </div>
      </div>
    </div>
    """
  end

  def prev_class(assigns) do
    ~H"""
    <%= if assigns.skill_class.class != 1 do %>
      <p class="border p-[2px] mb-1 rounded-full hidden lg:flex">
        <.link patch={"#{@path}?#{build_query(@query, %{"class" => @skill_class.class - 1})}"}>
          <.icon name="hero-chevron-left"/>
        </.link>
      </p>
    <% else %>
      <div />
    <% end %>
    """
  end

  def next_class(assigns) do
    ~H"""
    <%= if assigns.skill_class.class != 3 do %>
      <p class="border p-[2px] mb-1 rounded-full hidden lg:flex">
        <.link patch={"#{@path}?#{build_query(@query, %{"class" => @skill_class.class + 1})}"}>
          <.icon name="hero-chevron-right"/>
        </.link>
      </p>
    <% else %>
      <div />
    <% end %>
    """
  end

  defp minute_per_skill, do: @minute_per_skill

  defp get_level(counter, num_skills) do
    SkillScores.calc_high_skills_percentage(counter.high, num_skills)
    |> SkillScores.get_level()
  end

  defp build_query(base, query) do
    base
    |> Map.merge(query)
    |> URI.encode_query()
  end
end
