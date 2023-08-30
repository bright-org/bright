defmodule BrightWeb.SkillPanelLive.SkillPanelComponents do
  use Phoenix.Component
  import BrightWeb.ChartComponents
  import BrightWeb.ProfileComponents
  import BrightWeb.MegaMenuComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper, only: [calc_percentage: 2]

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
    <div class="flex gap-x-4 px-10 pt-4 pb-3">
      <.target_switch current_user={@current_user} />
      <.skill_panel_switch
        display_user={@display_user}
        me={@me}
        anonymous={@anonymous}
        root={@root}
      />
    </div>
    """
  end

  def skill_panel_switch(assigns) do
    ~H"""
    <p class="leading-tight">対象スキルの<br />切り替え</p>
    <.mega_menu_button
      id="skill_panel_menu"
      label="スキル"
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

    <% # TODO: α版後にifを除去して表示 %>
    <.skill_set_menu :if={false} />
    """
  end

  def skill_set_menu(assigns) do
    ~H"""
      <button
        id="dropdownDefaultButton"
        data-dropdown-toggle="dropdown"
        data-dropdown-offset-skidding="20"
        data-dropdown-placement="bottom"
        class="text-white bg-brightGreen-300 rounded h-[35px] pl-3 flex items-center font-bold"
        type="button"
      >
        スキルセット
        <span class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-8px] before:bg-brightGray-50 before:w-[1px] before:h-[42px]">
          expand_more
        </span>
      </button>
      <!-- スキルセット menu -->
      <div
        id="dropdown"
        class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700"
      >
        <ul
          class="py-2 text-sm text-gray-700 dark:text-gray-200"
          aria-labelledby="dropdownDefaultButton"
        >
          <li>
            <a
              href="#"
              class="block px-4 py-3 hover:bg-brightGray-50"
            >全スキルセット</a>
          </li>
          <li>
            <a
              href="#"
              class="block px-4 py-3 hover:bg-brightGray-50"
            >エンジニア</a>
          </li>
          <li>
            <a
              href="#"
              class="block px-4 py-3 hover:bg-brightGray-50"
            >インフラ</a>
          </li>
          <li>
            <a
              href="#"
              class="block px-4 py-3 hover:bg-brightGray-50"
            >デザイナー</a>
          </li>
          <li>
            <a
              href="#"
              class="block px-4 py-3 hover:bg-brightGray-50"
            >マーケッター</a>
          </li>
        </ul>
      </div>
    """
  end

  def target_switch(assigns) do
    ~H"""
    <p class="leading-tight ml-4">対象者の<br />切り替え</p>
    <.related_user_menu current_user={@current_user} />
    <% # TODO: α版後にifを除去して表示 %>
    <.team_menu :if={false} current_user={@current_user} />
    """
  end

  def related_user_menu(assigns) do
    ~H"""
    <.mega_menu_button
      id="related_user_card_menu"
      label="個人"
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

  def team_menu(assigns) do
    ~H"""
    <button
      id="dropdownDefaultButton"
      data-dropdown-toggle="dropdown3"
      data-dropdown-offset-skidding="307"
      data-dropdown-placement="bottom"
      class="text-white bg-brightGreen-300 rounded-sm py-1.5 pl-3 flex items-center font-bold"
      type="button"
    >
      <span class="min-w-[6em]">チーム</span>
      <span class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-8px] before:bg-brightGray-50 before:w-[1px] before:h-[42px]">
        expand_more
      </span>
    </button>
    <!-- チーム menu -->
    <div
      id="dropdown3"
      class="z-10 hidden bg-white rounded-lg shadow w-[750px]"
    >
    <.live_component
        id="related_team_card"
        module={BrightWeb.CardLive.RelatedTeamCardComponent}
        current_user={@current_user}
        show_menu={false}
      />
    </div>
    """
  end

  def return_myself_button(assigns) do
    ~H"""
    <button phx-click="clear_display_user" class="text-brightGreen-300 border bg-white border-brightGreen-300 rounded px-3 font-bold">
      自分に戻す
    </button>
    """
  end

  def toggle_link(assigns) do
    ~H"""
      <div class="bg-white text-brightGray-500 rounded-full inline-flex text-sm font-bold h-10">
      <.link href="#">
        <button
          id="grid"
          class={
            "inline-flex items-center font-bold rounded-l-full px-6 py-2 " <>
            if @active == "graph", do: "button-toggle-active", else: ""
          }
        >
          成長パネル
        </button>
        </.link>
        <.link href="#">
          <button
            id="list"
            class={
              "inline-flex items-center font-bold rounded-r-full px-4 py-2 " <>
              if @active == "panel", do: "button-toggle-active", else: ""
            }
          >
            スキルパネル
          </button>
        </.link>
      </div>
    """
  end

  def class_tab(assigns) do
    ~H"""
    <ul class="flex text-center shadow relative z-1 -bottom-1 text-md font-bold text-brightGray-500 bg-brightGreen-50">
      <%= for {skill_class, skill_class_score} <- pair_skill_class_score(@skill_classes) do %>
        <%= if skill_class_score do %>
          <% current = @skill_class.class == skill_class.class %>
          <li class={current && "bg-white text-base"}>
            <.link id={"class_tab_#{skill_class.class}"} patch={"#{@path}?#{build_query(@query, %{"class" => skill_class.class})}"} class="inline-block p-4 pt-3" aria-current={current && "page"}>
              クラス<%= skill_class.class %> <%= if(current, do: skill_class.name, else: "") %>
              <span class="text-xl ml-4"><%= floor skill_class_score.percentage %></span>％
            </.link>
          </li>
        <% else %>
          <li class="bg-pureGray-600 text-pureGray-100">
            <span href="#" class="select-none inline-block p-4 pt-3">
              クラス<%= skill_class.class %>
              <span class="text-xl ml-4">0</span>％
            </span>
          </li>
        <% end %>
      <% end %>
    </ul>
    """
  end

  def profile_area(assigns) do
    # TODO: 自分に戻す、に対応が必要
    ~H"""
      <div class="flex justify-between">
        <div class="w-[850px] pt-6">
          <% # TODO: α版後にexcellent_person/anxious_personをtrueに変更して表示 %>
          <.profile
            user_name={@display_user.name}
            title={@display_user.user_profile.title}
            detail={@display_user.user_profile.detail}
            icon_file_path={Bright.UserProfiles.icon_url(@display_user.user_profile.icon_file_path)}
            display_excellent_person={false}
            display_anxious_person={false}
            display_return_to_yourself={true}
            display_sns={true}
            twitter_url={@display_user.user_profile.twitter_url}
            github_url={@display_user.user_profile.github_url}
            facebook_url={@display_user.user_profile.facebook_url}
            is_anonymous={@anonymous}
          />
        </div>
        <div class="mr-auto flex ml-7">
          <div class="w-20 mt-5">
            <.doughnut_graph data={skill_score_percentages(@counter, @num_skills)} id="doughnut-graph-single-sample1"/>
          </div>
          <div class="h-20 mt-5 ml-2 flex flex-wrap">
            <p class="text-brightGreen-300 font-bold w-full flex mt-2 mb-1">
              <.profile_skill_class_level level={@skill_class_score.level} />
            </p>
            <div class="flex flex-col w-24 pl-6">
              <div class="min-w-[4em] flex items-center">
                <span class={[score_mark_class(:high, :green), "inline-block mr-1"]}></span>
                <%= calc_percentage(@counter.high, @num_skills) %>％
              </div>
              <div class="min-w-[4em] flex items-center">
                <span class={[score_mark_class(:middle, :green), "inline-block mr-1"]}></span>
                <%= calc_percentage(@counter.middle, @num_skills) %>％
              </div>
            </div>
            <div class="text-right text-xs">
              エビデンスの登録率 <%= calc_percentage(@counter.evidence_filled, @num_skills) %>%<br />
              教材の学習率 <%= calc_percentage(@counter.reference_read, @num_skills) %>%<br />
              試験の受験率 <%= calc_percentage(@counter.exam_touch, @num_skills) %>%
            </div>
          </div>
        </div>
        <% # TODO: α版後にifを除去して表示 %>
        <div :if={false} class="mt-3 mr-3">
          <button class="flex items-center text-sm font-bold px-4 py-2 rounded !text-white bg-brightGray-900">
            <img src="/images/common/icons/up.svg" class="mr-2" />
            スキルアップする
          </button>
        </div>
      </div>
    """
  end

  def score_mark_class(mark, color) do
    mark = mark || :low

    [Map.get(@score_mark, mark), get_in(@score_mark_color, [color, mark])]
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
    high = calc_percentage(counter.high, num_skills)
    middle = calc_percentage(counter.middle, num_skills)
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
