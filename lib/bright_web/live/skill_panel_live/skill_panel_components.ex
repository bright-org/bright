defmodule BrightWeb.SkillPanelLive.SkillPanelComponents do
  use BrightWeb, :component
  import BrightWeb.ChartComponents
  import BrightWeb.ProfileComponents
  import BrightWeb.MegaMenuComponents
  import BrightWeb.GuideMessageComponents
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
    <div>
      <!--- スキルセットジェムの実装まで使用しない --->
      <section class="hidden accordion flex my-2 max-w-[1236px] lg:hidden mt-2 px-4">
        <div class="bg-brightGray-50 rounded w-full">
          <p
            id="close_navigation"
            class={
              "hidden bg-brightGray-900 cursor-pointer font-bold pl-2 pr-8 py-2 relative rounded select-none text-white text-sm hover:opacity-50 before:absolute before:block before:border-l-2 before:border-t-2 before:border-solid before:content-[&#39;&#39;] before:h-3 before:right-4 before:top-1/2 before:w-3 before:-mt-2 before:rotate-225 " <>
              open()
            }
            phx-click={
              JS.hide(to: "#switch")
              |> JS.hide(to: "#close_navigation")
              |> JS.show(to: "#open_navigation")
            }
          >
            表示するスキル／ユーザー／チームを切り替える
          </p>
          <p
            id="open_navigation"
            class={
              "bg-brightGray-900 cursor-pointer font-bold pl-2 pr-8 py-2 relative rounded select-none text-white text-sm hover:opacity-50 before:absolute before:block before:border-l-2 before:border-t-2 before:border-solid before:content-[&#39;&#39;] before:h-3 before:right-4 before:top-1/2 before:w-3 before:-mt-2 before:rotate-225 " <>
              close()
            }
            phx-click={
              JS.show(to: "#switch")
              |> JS.show(to: "#close_navigation")
              |> JS.hide(to: "#open_navigation")
            }
          >
            表示するスキル／ユーザー／チームを切り替える
          </p>
        </div>
      </section>
      <div id="switch" class="flex gap-x-2 lg:gap-x-4 mt-2 px-4 pb-4 lg:mt-4 lg:px-10 lg:pb-3">
        <.target_switch current_user={@current_user} />
        <.skill_panel_switch
          display_user={@display_user}
          me={@me}
          anonymous={@anonymous}
          root={@root}
        />
      </div>
    </div>
    """
  end

  defp close(),
    do: "before:-mt-2 before:rotate-225"

  defp open(),
    do: "rounded-bl-none rounded-br-none before:-mt-0.5 before:rotate-45"

  @spec skill_panel_switch(any()) :: Phoenix.LiveView.Rendered.t()
  def skill_panel_switch(assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row">
      <p class="text-xs lg:text-sm leading-tight my-2 lg:mt-0 lg:mb-0 lg:m-4">対象スキルの<br class="hidden lg:inline">切替</p>
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
    </div>
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
    <div class="flex flex-col lg:flex-row">
      <p class="text-xs lg:text-sm leading-tight my-2 lg:my-0 mb-2 lg:m-4 lg:mb-0">対象者の<br class="hidden lg:inline">切替</p>
      <.related_user_menu current_user={@current_user} />
    </div>
    <% # TODO: α版後にifを除去して表示 %>
    <div :if={false}>
      <p class="text-xs lg:text-sm leading-tight my-2 lg:my-0 mb-2 lg:m-4 lg:mb-0">対象チームの<br class="hidden lg:inline">切替</p>
      <.team_menu current_user={@current_user} />
    </div>
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
      <span class="min-w-[4em] lg:min-w-[6em]">チーム</span>
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
              class={"bg-white text-base w-full"}
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
              class={"w-full bg-brightGreen-50 text-brightGray-500"}
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
    <ul class="flex shadow relative z-1 text-base font-bold text-brightGray-500 bg-brightGreen-50 lg:-bottom-1 lg:text-center lg:text-md w-full lg:w-fit">
      <%= for {skill_class, skill_class_score} <- pair_skill_class_score(@skill_classes) do %>
        <%= if skill_class_score do %>
          <% current = @skill_class.class == skill_class.class %>
          <li id={"class_tab_#{skill_class.class}"} class={["grow", current && "bg-white text-base", "first:border-none last:border-none lg:border-x-4"]}>
            <.link
              patch={"#{@path}?#{build_query(@query, %{"class" => skill_class.class})}"}
              class="flex lg:justify-start items-center px-2 lg:px-4 py-1 lg:py-3 lg:text-base"
              aria-current={current && "page"}
            >
              <span class="text-sm lg:text-base" :if={current}>クラス<%= skill_class.class %></span>
              <span class="text-xs lg:text-base" :if={!current}>クラス<%= skill_class.class %></span>
              <span class="hidden lg:flex"><%= skill_class.name %></span>
              <span class="text-lg text-right lg:text-xl min-w-[32px] lg:min-w-0 ml-1 lg:ml-4"><%= floor skill_class_score.percentage %></span>％
            </.link>
          </li>
        <% else %>
          <li id={"class_tab_#{skill_class.class}"} class="grow lg:grow-0 bg-pureGray-600 text-pureGray-100 first:border-none last:border-none lg:border-x-4">
            <a href="#" class="flex items-center lg:select-none px-2 lg:px-4 py-1 lg:py-3 text-xs lg:text-base">
              <span class="text-xs lg:text-base">クラス<%= skill_class.class %></span>
              <span class="hidden lg:block"><%= skill_class.name %></span>
              <span class="text-lg text-right lg:text-xl min-w-[32px] lg:min-w-0 ml-1 lg:ml-4">0</span>％
            </a>
          </li>
        <% end %>
      <% end %>
    </ul>
    """
  end

  def profile_area(assigns) do
    ~H"""
      <div class="flex flex-col lg:justify-between lg:flex-row">
        <div class="lg:order-last mb-8 lg:mt-2 lg:mr-3 flex flex-col gap-y-2 lg:gap-y-4">
          <div
            class="flex justify-between items-center w-full lg:w-48 gap-x-2"
            :if={@display_skill_edit_button}
          >
            <.link
              patch={~p"/panels/#{@skill_panel}/edit?#{@query}"}
              id="link-skills-form"
              class="flex-1 flex items-center text-sm font-bold justify-center pl-6 py-3 relative rounded !text-white bg-brightGray-900 hover:opacity-50">
              <span class="absolute material-icons-outlined left-4 top-1/2 text-white !text-xl -translate-y-1/2">edit</span>
              スキル入力する
            </.link>

            <div
              :if={@display_skill_edit_button}
              id="btn-help-enter-skills-button"
              class="flex-none cursor-pointer"
              phx-click={JS.push("open", target: "#help-enter-skills-button") |> show("#help-enter-skills-button")}>
              <img class="w-8 h-8" src="/images/icon_help.svg" />
            </div>
          </div>

          <div class="lg:absolute lg:right-0 lg:top-16 lg:z-10 flex items-center lg:items-end flex-col">
            <% # スキル入力前メッセージ %>
            <% # NOTE: idはGAイベントトラッキング対象、変更の際は確認と共有必要 %>
            <.live_component
              :if={Map.get(@flash, "first_skills_edit")}
              module={BrightWeb.HelpMessageComponent}
              id="help-enter-skills">
              <.first_skills_edit_message />
            </.live_component>

            <% # スキル入力するボタン 手動表示メッセージ %>
            <% # NOTE: idはGAイベントトラッキング対象、変更の際は確認と共有必要 %>
            <.live_component
              module={BrightWeb.HelpMessageComponent}
              id="help-enter-skills-button"
              open={false}>
              <.enter_skills_help_message reference_from={"button"} />
            </.live_component>
          </div>

          <% # TODO: α版後にifを除去して表示 %>
          <button :if={false} class="flex items-center text-sm font-bold justify-center pl-6 py-3 relative rounded !text-white bg-brightGray-900 w-full lg:w-48 hover:opacity-50">
            <img src="/images/common/icons/up.svg" class="absolute left-4 top-1/2 -translate-y-1/2">
            スキルアップする
          </button>
        </div>

        <div class="pt-2 w-full lg:pt-6 lg:w-[850px]">
          <% # TODO: α版後にexcellent_person/anxious_personをtrueに変更して表示 %>
          <.profile_inline
            user_name={@display_user.name}
            title={@display_user.user_profile.title}
            detail={@display_user.user_profile.detail}
            icon_file_path={Bright.UserProfiles.icon_url(@display_user.user_profile.icon_file_path)}
            display_excellent_person={false}
            display_anxious_person={false}
            display_return_to_yourself={!@me}
            display_sns={true}
            twitter_url={@display_user.user_profile.twitter_url}
            github_url={@display_user.user_profile.github_url}
            facebook_url={@display_user.user_profile.facebook_url}
            is_anonymous={@anonymous}
          />
        </div>
        <div class="flex ml-8 mb-4 h-[80px] lg:ml-7">
          <div class="w-20 mt-5">
            <.doughnut_graph id="doughnut-graph-single" data={skill_score_percentages(@counter, @num_skills)} />
          </div>

          <.profile_score_stats
            skill_class_score={@skill_class_score}
            counter={@counter}
            num_skills={@num_skills}
          />
        </div>
      </div>
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

  defp profile_score_stats(assigns) do
    ~H"""
    <div id="profile_score_stats" class="h-20 mt-4 lg:ml-2 flex flex-wrap lg:mt-5">
      <p class="text-brightGreen-300 font-bold w-full flex ml-[7px] lg:ml-6 mt-2 mb-1">
        <.profile_skill_class_level level={@skill_class_score.level} />
      </p>
      <div class="flex flex-col mr-2 pl-2 lg:pl-6">
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
        エビデンスの登録率 <span class="evidence_percentage"><%= calc_percentage(@counter.evidence_filled, @num_skills) %>%</span><br />
        教材の学習率 <span class="reference_percentage"><%= calc_percentage(@counter.reference_read, @num_skills) %>%</span><br />
        試験の受験率 <span class="exam_percentage"><%= calc_percentage(@counter.exam_touch, @num_skills) %>%</span>
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
