defmodule BrightWeb.SkillPanelLive.SkillPanelComponents do
  use Phoenix.Component
  import BrightWeb.ChartComponents
  import BrightWeb.ProfileComponents

  def navigations(assigns) do
    ~H"""
    <div class="flex gap-x-4 px-10 pt-4 pb-3">
      <.skill_panel_switch current_user={@current_user} />
      <.target_switch current_user={@current_user} />
      <.return_myself_button />
    </div>
    """
  end

  def skill_panel_switch(assigns) do
    ~H"""
    <p class="leading-tight">対象スキルの<br />切り替え</p>
    <.skill_panel_menu current_user={@current_user} />
    <.skill_set_menu />
    """
  end

  def skill_panel_menu(assigns) do
    ~H"""
      <button
        id="dropdownOffsetButton"
        data-dropdown-toggle="dropdownOffset"
        data-dropdown-offset-skidding="320"
        data-dropdown-placement="bottom"
        class="text-white bg-brightGreen-300 rounded-sm pl-3 flex items-center font-bold h-[35px]"
        type="button"
      >
        <span class="min-w-[6em]">スキルパネル</span>
        <span class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-8px] before:bg-brightGray-50 before:w-[1px] before:h-[42px]">
          expand_more
        </span>
      </button>

      <!-- スキルパネル menu -->
      <div
        id="dropdownOffset"
        class="z-10 hidden bg-white rounded-sm shadow"
      >
        <.live_component
          id="skill_card"
          module={BrightWeb.CardLive.SkillCardComponent}
          current_user={@current_user}
        />
      </div>
    """
  end

  def skill_set_menu(assigns) do
    ~H"""
      <button
        id="dropdownDefaultButton"
        data-dropdown-toggle="dropdown"
        data-dropdown-offset-skidding="20"
        data-dropdown-placement="bottom"
        class="text-white bg-brightGreen-300 rounded-sm h-[35px] pl-3 flex items-center font-bold"
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
      <.individual_menu current_user={@current_user} />
      <.team_menu current_user={@current_user} />
    """
  end

  def individual_menu(assigns) do
    ~H"""
      <button
        id="dropdownDefaultButton"
        data-dropdown-toggle="dropdown2"
        data-dropdown-offset-skidding="302"
        data-dropdown-placement="bottom"
        class="text-white bg-brightGreen-300 rounded-sm py-1.5 pl-3 flex items-center font-bold"
        type="button"
      >
        <span class="min-w-[6em]">個人</span>
        <span class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-8px] before:bg-brightGray-50 before:w-[1px] before:h-[42px]">
          expand_more
        </span>
      </button>
      <!-- 個人 menu -->
      <div
        id="dropdown2"
        class="z-10 hidden bg-whiterounded-lg shadow w-[750px]"
      >
        <.live_component
          id="intriguing_card"
          module={BrightWeb.CardLive.IntriguingCardComponent}
          current_user={@current_user}
          display_menu={false}
        />
      </div>
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
        show_menue={false}
      />
    </div>
    """
  end

  def return_myself_button(assigns) do
    ~H"""
      <button class="text-brightGreen-300 border bg-white border-brightGreen-300 rounded px-3 font-bold">
        自分に戻す
      </button>
    """
  end

  def toggle_link(assigns) do
    ~H"""
      <div class="bg-white text-brightGray-500 rounded-full inline-flex text-sm font-bold h-10">
      <.link href={"/panels/dummy_id/graph"}>
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
        <.link href={"/panels/#{@skill_panel.id}/skills?class=1"}>
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
        <li class="bg-white text-base">
          <a id="class_tab_1" href="#" class="inline-block p-4 pt-3" aria-current="page">
            <%= @skill_class.name %> <span class="text-xl ml-4">52</span>％
          </a>
        </li>
        <li class="">
          <a id="class_tab_2" href="#" class="inline-block p-4 pt-3">
            クラス2 <span class="text-xl ml-4">52</span>％
          </a>
        </li>
        <li class="">
          <a id="class_tab_3" href="#" class="inline-block p-4 pt-3">
          クラス3 <span class="text-xl ml-4">52</span>％
        </a>
        </li>
      </ul>
    """
  end

  def profile_area(assigns) do
    ~H"""
      <div class="flex justify-between">
        <div class="w-[850px] pt-6">
          <.profile
            user_name={@current_user.name}
            title={@current_user.user_profile.title}
            icon_file_path={@current_user.user_profile.icon_file_path}
            display_excellent_person={true}
            display_anxious_person={true}
            display_return_to_yourself={true}
            display_sns={true}
            twitter_url={@current_user.user_profile.twitter_url}
            github_url={@current_user.user_profile.github_url}
            facebook_url={@current_user.user_profile.facebook_url}
            display_detail={false}
          />
        </div>
        <div class="mr-auto flex ml-7">
          <div class="w-20 mt-auto">
            <.doughnut_graph data={[30, 20, 10]} id="doughnut-graph-single-sample1"/>
          </div>
          <div class="h-20 mt-5 ml-2 flex flex-wrap">
            <p class="text-brightGreen-300 font-bold w-full flex mt-2 mb-1">
              <img
                src="/images/common/icons/crown.svg"
                class="mr-2"
              />ベテラン
            </p>
            <div class="flex flex-col w-24 pl-6">
              <div class="min-w-[4em] flex items-center">
                <span class="h-4 w-4 rounded-full bg-brightGreen-600 inline-block mr-1"></span>
                68％
              </div>
              <div class="min-w-[4em] flex items-center">
                <span class="h-0 w-0 border-solid border-t-0 border-r-8 border-l-8 border-transparent border-b-[14px] border-b-brightGreen-300 inline-block mr-1"></span>
                12％
              </div>
            </div>
            <div class="text-right text-xs">
              エビデンスの登録率 30%<br />
              教材の学習率 30%<br />
              試験の合格率 30%
            </div>
          </div>
        </div>
        <div class="mt-3 mr-3">
          <button class="flex items-center text-sm font-bold px-4 py-2 rounded !text-white bg-brightGray-900">
            <img src="/images/common/icons/up.svg" class="mr-2" />
            スキルアップする
          </button>
        </div>
      </div>
    """
  end
end
