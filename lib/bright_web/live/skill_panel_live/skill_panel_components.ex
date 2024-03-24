defmodule BrightWeb.SkillPanelLive.SkillPanelComponents do
  use BrightWeb, :component

  import BrightWeb.ProfileComponents
  import BrightWeb.MegaMenuComponents

  alias Bright.SkillScores
  alias Bright.SkillEvidences
  alias Bright.SkillReferences
  alias Bright.SkillExams
  alias BrightWeb.PathHelper

  # スコア（〇 △ー） 各スタイルと色の定義
  @score_mark %{
    high: "high h-4 w-4 rounded-full",
    middle:
      "h-0 w-0 border-solid border-t-0 border-r-8 border-l-8 border-transparent border-b-[14px]",
    low: "h-1 w-4"
  }

  @score_mark_color %{
    green: %{
      high: "bg-skillPanel-brightGreen600",
      middle: "border-b-skillPanel-brightGreen300",
      low: "bg-brightGray-200"
    },
    amethyst: %{
      high: "bg-skillPanel-amethyst600",
      middle: "border-b-skillPanel-amethyst300",
      low: "bg-brightGray-200"
    },
    gray: %{
      high: "bg-brightGray-500",
      middle: "border-b-brightGray-300",
      low: "bg-brightGray-200"
    }
  }

  def navigations(assigns) do
    ~H"""
    <div id="switch" class="flex flex-col lg:flex-row gap-y-4 lg:gap-x-2 pb-4 lg:pb-3">
      <.target_switch current_user={@current_user} />
      <.skill_panel_switch
        display_user={@display_user}
        me={@me}
        anonymous={@anonymous}
        root="panels"
      />
    </div>
    """
  end

  @spec skill_panel_switch(any()) :: Phoenix.LiveView.Rendered.t()
  def skill_panel_switch(assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row">
      <.mega_menu_button
        id="skill_panel_menu"
        label="対象スキルの切替"
        dropdown_offset_skidding="307"
      >
        <.live_component
          id="skill_card"
          module={BrightWeb.CardLive.SkillCardComponent}
          display_user={@display_user}
          me={@me}
          anonymous={@anonymous}
          root={@root}
        />
      </.mega_menu_button>
    </div>
    """
  end

  def target_switch(assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row">
      <.related_user_menu current_user={@current_user} />
    </div>
    """
  end

  def related_user_menu(assigns) do
    ~H"""
    <.mega_menu_button
      id="related_user_card_menu"
      label="表示対象者を切替"
      dropdown_offset_skidding="307"
    >
      <.live_component
        id="related_user"
        module={BrightWeb.CardLive.RelatedUserCardComponent}
        current_user={@current_user}
        display_menu={false}
        purpose="menu"
      />
    </.mega_menu_button>
    """
  end

  def toggle_link(assigns) do
    ~H"""
    <div class="bg-white text-brightGray-500 rounded-full inline-flex flex-row text-sm font-bold h-10">
      <.link navigate={"#{PathHelper.skill_panel_path("graphs", @skill_panel, @display_user, @me, @anonymous)}?class=#{@skill_class}"}>
        <button
          class={
            "inline-flex items-center font-bold rounded-l-full px-6 py-2 " <>
            if @active == "graph", do: "button-toggle-active", else: "hover:opacity-50"
          }
        >
          成長パネル
        </button>
      </.link>
      <.link navigate={"#{PathHelper.skill_panel_path("panels", @skill_panel, @display_user, @me, @anonymous)}?class=#{@skill_class}"}>
        <button
          class={
            "inline-flex items-center font-bold rounded-r-full px-4 py-2 " <>
            if @active == "panel", do: "button-toggle-active", else: "hover:opacity-50"
          }
        >
          スキルパネル
        </button>
      </.link>
    </div>
    """
  end

  attr :user, Bright.Accounts.User
  attr :user_skill_class_score, :map
  attr :select_skill_class, Bright.SkillPanels.SkillClass
  attr :skill_class_tab_click_target, :any, default: nil

  def team_member_class_tab(assigns) do
    # チーム表示用以下の都合で専用の関数を用意
    # userを起点にpre_loadしていった場合、skill_score.skill_classの構造になる為pair_skill_class_score関数に対応できない
    # チームスキル分析でタブをタップした場合の挙動をハンドラで実装したい
    ~H"""
    <ul class="flex text-md font-bold text-brightGray-500 bg-skillGem-50 content-between w-full">
      <%= for %{skill_class: skill_class, skill_class_score: skill_class_score} <- @user_skill_class_score do %>
        <%= if skill_class_score do %>
          <% current = @select_skill_class.class == skill_class.class %>
          <%= if @select_skill_class.class == skill_class.class do %>
            <li
              class={"bg-white text-base w-full cursor-pointer"}
              phx-click="skill_class_tab_click"
              phx-target={@skill_class_tab_click_target}
              phx-value-user_id={@user.id}
              phx-value-skill_class_id={skill_class.id}
            >
              <span
                id={"class_tab_#{skill_class.class}"}
                class="inline-block p-4 pt-3"
                aria-current={current && "page"}
              >
                クラス<%= skill_class.class %>
              <span class="text-xl ml-4">
                <%= floor skill_class_score.percentage %></span>％
              </span>
            </li>
          <% else %>

            <li
              class={"w-full bg-brightGreen-50 text-brightGray-500 cursor-pointer"}
              phx-click="skill_class_tab_click"
              phx-target={@skill_class_tab_click_target}
              phx-value-user_id={@user.id}
              phx-value-skill_class_id={skill_class.id}
            >
              <span
                id={"class_tab_#{skill_class.class}"}
                class="inline-block p-4 pt-3"
              >
                クラス<%= skill_class.class %>
                <span class="text-xl ml-4">
                <%= floor skill_class_score.percentage %></span>％
              </span>
            </li>
          <% end %>
        <% else %>
          <li class="w-full bg-pureGray-600 text-pureGray-100">
            <span
              class="select-none inline-block p-4 pt-3"
            >
              クラス<%= skill_class.class %>
              <span class="text-xl ml-4">0</span>％
            </span>
          </li>
        <% end %>
      <% end %>
    </ul>
    """
  end

  def class_tab(assigns) do
    ~H"""
    <div class="w-full bg-white border-b border-b-brightGray-100">
      <ul class="flex relative z-1 text-normal font-bold text-brightGray-300 text-center lg:text-md w-full lg:w-fit">
        <%= for {skill_class, skill_class_score} <- pair_skill_class_score(@skill_classes) do %>
          <% current = @skill_class.class == skill_class.class %>
          <%= if !@me && is_nil(skill_class_score) do %>
            <li id={"class_tab_#{skill_class.class}"} class="grow lg:grow-0">
              <a href="#" class="hover:cursor-default flex items-center lg:select-none px-2 lg:px-4 py-1 lg:py-3 text-xs">
                <span class="text-sm lg:text-normal">クラス<%= skill_class.class %></span>
                <span class="text-lg text-right lg:text-xl min-w-[32px] lg:min-w-0 ml-1 lg:ml-4">0％</span>
              </a>
            </li>
          <% else %>
            <li id={"class_tab_#{skill_class.class}"} class={["grow", current && "text-brightGreen-300 border-b-2 border-b-brightGreen-300", !current && "hover:opacity-50 hover:text-brightGreen-300"]}>
              <.link
                patch={"#{@path}?#{build_query(@query, %{"class" => skill_class.class})}"}
                class="flex justify-center items-center px-1 lg:px-4 py-1 lg:py-3"
                aria-current={current && "page"}
              >
                <span class="text-sm lg:text-normal">クラス<%= skill_class.class %></span>
                <span class="text-lg text-right lg:text-xl min-w-[32px] lg:min-w-0 ml-1 lg:ml-4">
                  <%= if skill_class_score do %>
                    <%= floor skill_class_score.percentage %>
                  <% else %>
                    0
                  <% end %>
                  ％
                </span>
              </.link>
            </li>
          <% end %>
        <% end %>
      </ul>
    </div>
    """
  end

  def profile_area(assigns) do
    ~H"""
      <.profile_with_selected_skill_class
          user_name={@display_user.name}
          title={@display_user.user_profile.title}
          icon_file_path={Bright.UserProfiles.icon_url(@display_user.user_profile.icon_file_path)}
          display_return_to_yourself={!@me}
          is_anonymous={@anonymous}
      />
    """
  end

  def no_skill_panel(assigns) do
    ~H"""
    <div class="h-screen w-full flex flex-col justify-center items-center gap-y-2">
      <p class="text-2xl lg:text-4xl">スキルパネルがありません</p>
      <p class="text-md lg:text-xl">スキルを選ぶからスキルパネルを取得しましょう</p>
      <a href={~p"/onboardings"} class="text-xl cursor-pointer bg-brightGray-900 !text-white font-bold px-6 py-4 rounded mt-10 hover:opacity-50">
      スキルを選ぶ
      </a>
    </div>
    """
  end

  def score_mark_class(mark, color) do
    mark = mark || :low

    [Map.get(@score_mark, mark), get_in(@score_mark_color, [color, mark])]
  end

  def profile_score_stats(assigns) do
    ~H"""
    <div id="profile_score_stats" class="h-20 lg:ml-2 flex flex-wrap">
      <p class="text-brightGreen-300 font-bold w-full flex ml-[7px] lg:ml-6 mt-2 mb-1">
        <.profile_skill_class_level level={@skill_class_score.level} />
      </p>
      <div class="flex flex-col mr-2 pl-2 lg:pl-6">
        <div class="min-w-[4em] flex items-center">
          <span class={[score_mark_class(:high, :green), "inline-block mr-1"]}></span>
          <%= SkillScores.calc_high_skills_percentage(@counter.high, @num_skills) %>％
        </div>
        <div class="min-w-[4em] flex items-center">
          <span class={[score_mark_class(:middle, :green), "inline-block mr-1"]}></span>
          <%= SkillScores.calc_middle_skills_percentage(@counter.middle, @num_skills) %>％
        </div>
      </div>
      <div class="text-right text-xs">
        学習メモの登録率 <span class="evidence_percentage"><%= SkillEvidences.calc_filled_percentage(@counter.evidence_filled, @num_skills) %>%</span><br />
        教材の学習率 <span class="reference_percentage"><%= SkillReferences.calc_read_percentage(@counter.reference_read, @num_skills) %>%</span><br />
        試験の受験率 <span class="exam_percentage"><%= SkillExams.calc_touch_percentage(@counter.exam_touch, @num_skills) %>%</span>
      </div>
    </div>
    """
  end

  def profile_skill_class_level(%{level: :beginner} = assigns) do
    ~H"""
    <img src="/images/common/icons/beginner.svg" class="mr-2" />見習い
    """
  end

  def profile_skill_class_level(%{level: :normal} = assigns) do
    ~H"""
    <img src="/images/common/icons/crown_copper.svg" class="mr-2" />平均
    """
  end

  def profile_skill_class_level(%{level: :skilled} = assigns) do
    ~H"""
    <img src="/images/common/icons/crown.svg" class="mr-2" />ベテラン
    """
  end

  def skill_score_percentages(counter, num_skills) do
    high = SkillScores.calc_high_skills_percentage(counter.high, num_skills)
    middle = SkillScores.calc_middle_skills_percentage(counter.middle, num_skills)
    low = 100 - high - middle

    [high, middle, low]
  end

  defp pair_skill_class_score(nil), do: []

  defp pair_skill_class_score(skill_classes) do
    skill_classes
    |> Enum.map(fn skill_class ->
      skill_class.skill_class_scores
      |> case do
        [] -> {skill_class, nil}
        [skill_class_score] -> {skill_class, skill_class_score}
      end
    end)
  end

  defp build_query(base, query) do
    base
    |> Map.merge(query)
    |> URI.encode_query()
  end
end
