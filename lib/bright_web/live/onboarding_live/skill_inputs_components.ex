defmodule BrightWeb.OnboardingLive.SkillInputsComponents do
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
        root="skills"
        anonymous={@anonymous}
        career_field={nil}
        current_skill_class={@skill_class}
        per_page={10}
      />
      </div>
    </.mega_menu_button>
    """
  end

  def gem_carousel(assigns) do
    ~H"""
    <div class="lg:w-[4000px] mt-8 flex lg:overflow-x-hidden">
      <%= for class <- @skill_classes do %>
        <%= if class.id == @skill_class.id do %>
        <div class={"w-full lg:w-[40vw] #{margin(class.class, @skill_class.class)}"}>
          <.gem_area
            class={class.class}
            path={@path}
            query={@query}
            links={@links}
            skill_panel={@skill_panel}
            skill_class={class}
            counter={@counter}
            num_skills={@num_skills}
            gem_labels={@gem_labels}
            gem_values={@gem_values}
            share_graph_url={@share_graph_url}
            color={Map.get(@color,class.class)}
            show_qr={true}
          />
        </div>
        <% else %>
        <div class="hidden lg:block">
          <div id={"class-#{class.id}"} class={"w-[40vw] #{margin(class.class, @skill_class.class)}"} phx-update="ignore">
          <.non_active_gem_area
            class_num={class.class}
            path={@path}
            query={@query}
            skill_panel={@skill_panel}
            class={class}
            prev_skill_class={@prev_skill_class}
            next_skill_class={@next_skill_class}
            color={Map.get(@color, class.class)}
            show_qr={false}
            current_class={@skill_class.class}
          />
          </div>
        </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  def non_active_gem_area(%{current_class: current, class_num: class} = assigns) do
    case {class, current} do
      {2, 1} -> next_gem_area(assigns)
      {3, 1} -> hidden_gem_area(assigns)
      {1, 2} -> prev_gem_area(assigns)
      {3, 2} -> next_gem_area(assigns)
      {1, 3} -> hidden_gem_area(assigns)
      {2, 3} -> prev_gem_area(assigns)
    end
  end

  def next_gem_area(assigns) do
    ~H"""
    <.gem_area
        class={@class_num}
        path={@path}
        query={@query}
        skill_panel={@skill_panel}
        skill_class={@class}
        links={@next_skill_class.links}
        counter={@next_skill_class.counter}
        num_skills={@next_skill_class.num_skills}
        gem_labels={@next_skill_class.gem_labels}
        gem_values={@next_skill_class.gem_values}
        share_graph_url={""}
        color={@color}
        show_qr={false}
      />
    """
  end

  def prev_gem_area(assigns) do
    ~H"""
    <.gem_area
        class={@class.class}
        path={@path}
        query={@query}
        skill_panel={@skill_panel}
        skill_class={@class}
        links={@prev_skill_class.links}
        counter={@prev_skill_class.counter}
        num_skills={@prev_skill_class.num_skills}
        gem_labels={@prev_skill_class.gem_labels}
        gem_values={@prev_skill_class.gem_values}
        share_graph_url={""}
        color={@color}
        show_qr={false}
      />
    """
  end

  def hidden_gem_area(assigns) do
    ~H"""
    <div />
    """
  end

  def gem_area(assigns) do
    ~H"""
    <div class="bg-white rounded-lg flex flex-col py-8 h-full lg:h-[470px]">
      <div class="lg:hidden flex justify-between -mt-4 px-4">
        <.prev_class skill_class={@skill_class} path={@path} query={@query} />
        <.next_class skill_class={@skill_class} path={@path} query={@query}/>
      </div>

      <div class="flex justify-center">
        <span class={"#{@color} text-white py-[3px] px-2 rounded-lg mr-1"}>クラス<%= @skill_class.class %></span>
        <span class="font-bold"><%= @skill_class.name %></span>
      </div>
      <div class="flex flex-col lg:flex-row items-center justify-between mt-1 lg:px-4">
        <div class="hidden lg:block"><.prev_class skill_class={@skill_class} path={@path} query={@query} /></div>
        <div class="flex justify-center flex-col">
          <div phx-click="scroll_to_unit">
            <.skill_gem
              id={"sk-#{@skill_class.id}-#{@class}"}
              labels={@gem_labels}
              data={[@gem_values]}
              size="base"
              links={@links}
              display_link="true"
            />
          </div>
          <div class="flex flex-col lg:flex-row px-2 lg:px-0 gap-x-2">
            <.skill_stat counter={@counter}  num_skills={@num_skills} />
            <div class="flex gap-x-2 items-end px-8 lg:px-0 -mt-8 lg:mt-0" :if={@show_qr}>
              <SnsComponents.sns_share_button_group share_graph_url={@share_graph_url} skill_panel={@skill_panel.name} direction="lg:flex-col lg:justify-between lg:h-[75px] lg:py-1" />
              <QrCodeComponents.qr_code_image class="border border-b-2 border-brightGray-200" qr_code_url={@share_graph_url} width="80px" height="80px" />
            </div>
          </div>
        </div>
        <div class="hidden lg:block"><.next_class skill_class={@skill_class} path={@path} query={@query}/></div>
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
      <p class="border p-[2px] mb-1 rounded-full">
        <.link navigate={"#{@path}?#{build_query(@query, %{"class" => @skill_class.class - 1})}"}>
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
      <p class="border p-[2px] mb-1 rounded-full">
        <.link navigate={"#{@path}?#{build_query(@query, %{"class" => @skill_class.class + 1})}"}>
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

  defp margin(class, current_class) do
    case {class, current_class} do
      {1, 1} -> "ml-[30vw] mr-6"
      {2, 1} -> "mx-12"
      {3, 1} -> "hidden"
      {1, 2} -> "-ml-[20vw] mr-6"
      {2, 2} -> "mx-12"
      {3, 2} -> "mx-6"
      {1, 3} -> "hidden"
      {2, 3} -> "-ml-[20vw] mr-6"
      {3, 3} -> "mx-12 mr-[20vw]"
    end
  end
end
