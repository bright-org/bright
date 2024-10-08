defmodule BrightWeb.SkillPanelLive.SkillPanelComponents do
  use BrightWeb, :component

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
    <div id="switch" class="flex flex-col lg:flex-row gap-y-2 lg:gap-y-0 lg:gap-x-2">
      <.target_user_switch current_user={@current_user} />
    </div>
    """
  end

  @spec skill_panel_switch(any()) :: Phoenix.LiveView.Rendered.t()
  def skill_panel_switch(assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row">
      <.mega_menu_button
        id="skill_panel_menu"
        dropdown_offset_skidding="307"
      >
        <:button_content>
          <div
            class={[
              "h-5 w-5 [mask-image:url('/images/common/icons/skillSelect.svg')] [mask-position:center_center] [mask-size:100%] [mask-repeat:no-repeat] bg-white"]
            }
          />
          対象スキルの切替
        </:button_content>
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

  def target_user_switch(assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row">
      <.related_user_menu current_user={@current_user} />
    </div>
    """
  end

  @spec related_user_menu(any()) :: Phoenix.LiveView.Rendered.t()
  def related_user_menu(assigns) do
    ~H"""
    <.mega_menu_button
      id="related_user_card_menu"
      dropdown_offset_skidding="307"
    >
      <:button_content>
        <div
          class={[
            "inline-block h-5 w-5 [mask-image:url('/images/common/icons/switchIndividual.svg')] [mask-position:center_center] [mask-size:100%] [mask-repeat:no-repeat] bg-white"]
          }
        />
        表示対象者を切替
      </:button_content>
      <.live_component
        id="related_user"
        module={BrightWeb.CardLive.RelatedUserCardComponent}
        current_user={@current_user}
        purpose="menu"
      />
    </.mega_menu_button>
    """
  end

  # NOTE: svg に css で色を付けるために mask-xxx プロパティを使用している
  def toggle_link(assigns) do
    ~H"""
    <div class="bg-white text-brightGray-500 rounded-full inline-flex flex-row text-sm font-bold h-10">
      <.link navigate={"#{PathHelper.skill_panel_path("skills", @skill_panel, @display_user, @me, @anonymous)}?class=#{@skill_class}"}>
        <button
          class={
            "inline-flex items-center font-bold rounded-l-full gap-x-2 px-6 py-2 " <>
            if @active == "skills", do: "button-toggle-active", else: "hover:filter hover:brightness-[80%]"
          }
        >
          <div
            class={[
              "inline-block h-6 w-6 [mask-image:url('/images/common/icons/growthPanel.svg')] [mask-position:center_center] [mask-size:100%] [mask-repeat:no-repeat]",
              @active == "skills" && "bg-white", @active != "skills" && "bg-brightGray-500"]
            }
          />
          スキル入力
        </button>
      </.link>
      <.link navigate={"#{PathHelper.skill_panel_path("panels", @skill_panel, @display_user, @me, @anonymous)}?class=#{@skill_class}"}>
        <button
          class={
            "inline-flex items-center font-bold rounded-r-full gap-x-2 px-4 py-2 " <>
            if @active == "panel", do: "button-toggle-active", else: "hover:filter hover:brightness-[80%]"
          }
        >
          <div
            class={[
              "inline-block h-6 w-6 [mask-image:url('/images/common/icons/skillPanel.svg')] [mask-position:center_center] [mask-size:100%] [mask-repeat:no-repeat]",
              @active == "panel" && "bg-white", @active != "panel" && "bg-brightGray-500"]
            }
          />
          スキル比較
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
    <ul class="flex bg-white text-normal lg:text-md font-bold text-brightGray-300 text-center">
      <.team_member_class_tab_content
        user={@user}
        user_skill_class_score={@user_skill_class_score}
        select_skill_class={@select_skill_class}
        skill_class_tab_click_target={@skill_class_tab_click_target}
      />
    </ul>
    """
  end

  defp team_member_class_tab_content(%{user_skill_class_score: nil} = assigns) do
    ~H"""
    <li class="h-14" />
    """
  end

  defp team_member_class_tab_content(assigns) do
    ~H"""
    <%= for %{skill_class: skill_class, skill_class_score: skill_class_score} <- @user_skill_class_score do %>
      <li class="w-1 lg:w-2 border-b-2 border-b-brightGreen-300"></li>
      <%= if skill_class_score do %>
        <li
          class={
            [
              "flex grow cursor-pointer justify-center items-center rounded-t px-1 lg:px-4 py-1 lg:py-3",
              selected_skill?(@select_skill_class, skill_class) && "text-brightGreen-300 border-x-2 border-x-brightGreen-300 border-t-2 border-t-brightGreen-300",
              !selected_skill?(@select_skill_class, skill_class) && "hover:filter hover:brightness-[80%] hover:text-brightGreen-300 border-x-2 border-x-brightGray-100 border-t-2 border-t-brightGray-100 border-b-2 border-b-brightGreen-300"
            ]
          }
          phx-click="skill_class_tab_click"
          phx-target={@skill_class_tab_click_target}
          phx-value-user_id={@user.id}
          phx-value-skill_class_id={skill_class.id}
        >
          <span
            class="text-sm lg:text-normal"
            aria-current={selected_skill?(@select_skill_class, skill_class) && "page"}
          >
            クラス<%= skill_class.class %>：
          <span class="text-sm text-right lg:text-normal min-w-[32px] lg:min-w-0">
            <%= floor skill_class_score.percentage %></span>％
          </span>
        </li>
      <% else %>
        <li class="flex grow rounded-t bg-pureGray-600 text-pureGray-100 flex justify-center items-center px-1 lg:px-4 py-1 lg:py-3">
          <span
            class="select-none text-sm lg:text-normal"
          >
            クラス<%= skill_class.class %>：
            <span class="text-sm text-right lg:text-normal min-w-[32px] lg:min-w-0">0</span>％
          </span>
        </li>
      <% end %>
    <% end %>
    <li class="w-1 lg:w-2 border-b-2 border-b-brightGreen-300"></li>
    """
  end

  def class_tab(assigns) do
    ~H"""
    <div class="w-full bg-white">
      <ul class="flex relative z-1 text-normal font-bold text-brightGray-300 text-center lg:text-md w-full">
        <%= for {skill_class, skill_class_score} <- pair_skill_class_score(@skill_classes) do %>
          <li class="w-1 lg:w-2 border-b-2 border-b-brightGreen-300"></li>
          <li id={"class_tab_#{skill_class.class}"} class={["grow lg:grow-0 rounded-t", selected_skill?(@skill_class, skill_class) && "text-brightGreen-300 border-x-2 border-x-brightGreen-300 border-t-2 border-t-brightGreen-300", !selected_skill?(@skill_class, skill_class) && "hover:filter hover:brightness-[80%] hover:text-brightGreen-300 border-x-2 border-x-brightGray-100 border-t-2 border-t-brightGray-100 border-b-2 border-b-brightGreen-300"]}>
            <.link
              patch={"#{@path}?#{build_query(@query, %{"class" => skill_class.class})}"}
              class="flex justify-center items-center px-1 lg:px-10 py-2"
              aria-current={selected_skill?(@skill_class, skill_class) && "page"}
            >
              <span class="text-sm lg:text-normal">クラス<%= skill_class.class %>：</span>
              <span class="text-sm text-right lg:text-normal min-w-[32px] lg:min-w-0">
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
        <li class="grow border-b-2 border-b-brightGreen-300"></li>
      </ul>
    </div>
    """
  end

  defp selected_skill?(current_skill_class, target_skill_class) do
    current_skill_class.class == target_skill_class.class
  end

  def no_skill_panel(assigns) do
    ~H"""
    <div class="h-screen w-full flex flex-col justify-center items-center gap-y-2">
      <p class="text-2xl lg:text-4xl">スキルパネルがありません</p>
      <p class="text-md lg:text-xl">スキルを選ぶからスキルパネルを取得しましょう</p>
      <a href={~p"/onboardings"} class="text-xl cursor-pointer bg-brightGray-900 !text-white font-bold px-6 py-4 rounded mt-10 hover:filter hover:brightness-[80%]">
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
    <div id="profile_score_stats" class="h-20 lg:ml-2 flex flex-col">
      <p class="text-brightGreen-300 font-bold flex ml-[7px] lg:ml-4 mt-2 mb-1">
        <.profile_skill_class_level level={@skill_class_score.level} />
      </p>
      <div class="flex">
        <div class="flex flex-col mr-2 pl-2 lg:pl-4">
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
