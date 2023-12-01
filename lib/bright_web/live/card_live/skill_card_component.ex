# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.SkillCardComponent do
  @moduledoc """
  Skill Card Component
  """
  use BrightWeb, :live_component
  import BrightWeb.TabComponents
  alias Bright.{CareerFields, SkillPanels}
  alias BrightWeb.PathHelper
  alias Bright.Teams
  alias Bright.Teams.Team
  alias Bright.CustomGroups.CustomGroup

  @impl true
  def render(assigns) do
    # スキルパネル用のリダイレクト処理が定義されてない場合の初期値設定
    # PathHelper.skill_panel_pathを使用せずにクリック時のアクションを自分で用意したい時用
    assigns =
      assigns
      |> set_default_attrs()

    ~H"""
    <div>
      <.tab
        id="skill_card"
        selected_tab={@selected_tab}
        target={@myself}
        page={@page}
        total_pages={@total_pages}
        tabs={@tabs}
      >
        <div class="py-4 px-2 flex gap-y-4 flex-col lg:py-6 lg:px-7 lg:min-h-[464px]">
          <ul :if={Enum.count(@skill_panels) == 0} class="flex gap-y-2.5 flex-col">
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
              <%= Enum.into(@tabs, %{}) |> Map.get(@selected_tab) %>はありません
              </div>
            </li>
          </ul>
          <div :if={Enum.count(@skill_panels) > 0} class="hidden lg:flex">
            <div class="flex-1 text-left font-bold"></div>
            <div class="w-36 font-bold">クラス1</div>
            <div class="w-36 font-bold">クラス2</div>
            <div class="w-36 font-bold">クラス3</div>
          </div>
          <%= for skill_panel <- @skill_panels do %>
            <.skill_panel
              skill_panel={skill_panel}
              display_user={@display_user}
              me={@me}
              anonymous={@anonymous}
              root={@root}
              over_ride_on_card_row_click_target={@over_ride_on_card_row_click_target}
            />
          <% end %>
        </div>
      </.tab>
    </div>
    """
  end

  defp set_default_attrs(assigns) do
    assigns
    |> set_default_over_ride_on_card_row_click_target()
  end

  defp set_default_over_ride_on_card_row_click_target(
         %{over_ride_on_card_row_click_target: _over_ride_on_card_row_click_target} = assigns
       ) do
    assigns
  end

  defp set_default_over_ride_on_card_row_click_target(assigns) do
    assigns
    |> Map.put(:over_ride_on_card_row_click_target, false)
  end

  defp skill_panel(%{over_ride_on_card_row_click_target: true} = assigns) do
    # over_ride_on_card_row_click_target = true が指定されている場合、on_skill_pannel_clickで定義した呼び出し元の画面に処理をゆだねる
    skill_classes = assigns.skill_panel.skill_classes
    dummy_classes = cleate_dummy_classes(skill_classes)

    assigns =
      assigns
      |> assign(:skill_classes, skill_classes ++ dummy_classes)

    ~H"""
    <div class="flex flex-wrap lg:flex-nowrap">
      <div class="text-left font-bold w-full lg:flex-1 lg:w-fit">
        <p
          phx-click="on_skill_pannel_click"
          phx-value-skill_panel_id={@skill_panel.id}
        >
          <%= @skill_panel.name %>
        </p>
      </div>
      <%= for skill_class <- @skill_classes do %>
        <.skill_gem
          score={List.first(skill_class.skill_class_scores)}
          skill_class={skill_class}
          skill_panel={@skill_panel}
          display_user={@display_user}
          me={@me}
          anonymous={@anonymous}
          root={@root}
          over_ride_on_card_row_click_target={@over_ride_on_card_row_click_target}
        />
      <% end %>
    </div>
    """
  end

  defp skill_panel(assigns) do
    skill_classes = assigns.skill_panel.skill_classes
    dummy_classes = cleate_dummy_classes(skill_classes)

    assigns =
      assigns
      |> assign(:skill_classes, skill_classes ++ dummy_classes)

    ~H"""
    <div class="flex flex-wrap lg:flex-nowrap">
      <div class="text-left font-bold w-full mb-2 lg:mb-0 lg:flex-1 lg:w-fit">
        <%= @skill_panel.name %>
      </div>
      <%= for skill_class <- @skill_classes do %>
        <.skill_gem
          score={List.first(skill_class.skill_class_scores)}
          skill_class={skill_class}
          skill_panel={@skill_panel}
          display_user={@display_user}
          me={@me}
          anonymous={@anonymous}
          root={@root}
          over_ride_on_card_row_click_target={@over_ride_on_card_row_click_target}
        />
      <% end %>
    </div>
    """
  end

  defp cleate_dummy_classes(skill_classes) do
    dummy =
      %Bright.SkillPanels.SkillClass{}
      |> Map.put(:skill_class_scores, [nil])

    dummy_count = 3 - Enum.count(skill_classes)
    List.duplicate(dummy, dummy_count)
  end

  defp skill_gem(%{score: nil} = assigns) do
    ~H"""
    <div class="w-28 lg:w-36"></div>
    """
  end

  defp skill_gem(%{score: %{level: level}, over_ride_on_card_row_click_target: true} = assigns) do
    # over_ride_on_card_row_click_target = true が指定されている場合、on_skill_pannel_clickで定義した呼び出し元の画面に処理をゆだねる
    assigns =
      assigns
      |> assign(:icon_path, icon_path(level))
      |> assign(:level, level)

    ~H"""
    <div class="w-28 lg:w-36">
      <p
        phx-click="on_skill_class_click"
        phx-value-skill_panel_id={@skill_panel.id}
        phx-value-skill_class_id={@skill_class.id}
        class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1"
        >
        <img src={@icon_path} class="mr-1" />
        <span class="w-16"><%= level_text(@level) %></span>
      </p>
    </div>
    """
  end

  defp skill_gem(%{score: %{level: level}} = assigns) do
    assigns =
      assigns
      |> assign(:icon_path, icon_path(level))
      |> assign(:level, level)

    ~H"""
    <div class="w-28 lg:w-36">
      <.link href={PathHelper.skill_panel_path(@root, @skill_panel, @display_user, @me, @anonymous) <> "?class=#{@skill_class.class}"}>
        <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
          <img src={@icon_path} class="mr-1" />
          <span class="w-16"><%= level_text(@level) %></span>
        </p>
      </.link>
    </div>
    """
  end

  @impl true
  def update(%{display_team: display_team, display_user: display_user} = assigns, socket) do
    default_tab = "engineer"

    tabs =
      CareerFields.list_career_fields()
      |> Enum.map(&{&1.name_en, &1.name_ja})

    socket
    |> assign(assigns)
    |> assign_over_ride_on_card_row_click_target(assigns)
    |> assign(:tabs, tabs)
    |> assign(:selected_tab, default_tab)
    |> update_socket(display_team, display_user, default_tab)
  end

  @impl true
  def update(%{display_user: user} = assigns, socket) do
    tabs =
      CareerFields.list_career_fields()
      |> Enum.map(&{&1.name_en, &1.name_ja})

    socket
    |> assign(assigns)
    |> assign(:tabs, tabs)
    |> assign(:selected_tab, "engineer")
    |> assign_paginate(user.id, "engineer")
    |> then(&{:ok, &1})
  end

  def update(%{status: "level_changed"}, socket) do
    # 新しいスキルクラスを開放時のupdateを実施
    %{
      selected_tab: career_field,
      display_user: display_user,
      page: page
    } = socket.assigns

    {:ok, assign_paginate(socket, display_user.id, career_field, page)}
  end

  defp assign_over_ride_on_card_row_click_target(
         socket,
         %{over_ride_on_card_row_click_target: over_ride_on_card_row_click_target} = _assigns
       ) do
    socket
    |> assign(:over_ride_on_card_row_click_target, over_ride_on_card_row_click_target)
  end

  defp assign_over_ride_on_card_row_click_target(socket, _assigns) do
    socket
  end

  defp update_socket(socket, team, user, selected_tab) do
    socket
    |> assign_paginate_team(team, user, selected_tab)
    |> then(&{:ok, &1})
  end

  def assign_paginate_team(socket, team, user, career_field, page \\ 1)

  def assign_paginate_team(socket, %Team{} = team, _user, career_field, page) do
    user_ids =
      Teams.list_confirmed_team_member_users_by_team(team)
      |> Enum.map(& &1.user_id)

    %{page_number: page, total_pages: total_pages, entries: skill_panels} =
      SkillPanels.list_users_skill_panels_by_career_field(user_ids, career_field, page)

    socket
    |> assign(:skill_panels, skill_panels)
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
  end

  def assign_paginate_team(socket, %CustomGroup{} = custom_group, user, career_field, page) do
    user_ids =
      Bright.Repo.preload(custom_group, :member_users)
      |> Map.get(:member_users)
      |> Enum.map(& &1.user_id)
      |> Kernel.++([user.id])

    %{page_number: page, total_pages: total_pages, entries: skill_panels} =
      SkillPanels.list_users_skill_panels_by_career_field(user_ids, career_field, page)

    socket
    |> assign(:skill_panels, skill_panels)
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
  end

  def assign_paginate_team(socket, _team, user, career_field, page) do
    # TODO 要件不明 チームが取得出来ていない場合は個人の場合とおなじスキルパネルを取得する
    assign_paginate(socket, user.id, career_field, page)
  end

  def assign_paginate(socket, user_id, career_field, page \\ 1) do
    %{page_number: page, total_pages: total_pages, entries: skill_panels} =
      SkillPanels.list_users_skill_panels_by_career_field([user_id], career_field, page)

    socket
    |> assign(:skill_panels, skill_panels)
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"tab_name" => tab_name},
        %{assigns: %{display_team: team, display_user: user}} = socket
      ) do
    socket
    |> assign(:selected_tab, tab_name)
    |> assign_paginate_team(team, user, tab_name)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"tab_name" => tab_name},
        %{assigns: %{display_user: user}} = socket
      ) do
    socket
    |> assign(:selected_tab, tab_name)
    |> assign_paginate(user.id, tab_name)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "previous_button_click",
        _params,
        %{assigns: %{display_team: team, display_user: user}} = socket
      ) do
    %{page: page, selected_tab: tab_name} = socket.assigns
    page = if page - 1 < 1, do: 1, else: page - 1

    socket
    |> assign_paginate_team(team, user, tab_name, page)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "previous_button_click",
        _params,
        %{assigns: %{display_user: user}} = socket
      ) do
    %{page: page, selected_tab: tab_name} = socket.assigns
    page = if page - 1 < 1, do: 1, else: page - 1

    socket
    |> assign_paginate(user.id, tab_name, page)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "next_button_click",
        _params,
        %{assigns: %{display_team: team, display_user: user}} = socket
      ) do
    %{page: page, total_pages: total_pages, selected_tab: tab_name} = socket.assigns
    page = if page + 1 > total_pages, do: total_pages, else: page + 1

    socket
    |> assign_paginate_team(team, user, tab_name, page)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "next_button_click",
        _params,
        %{assigns: %{display_user: user}} = socket
      ) do
    %{page: page, total_pages: total_pages, selected_tab: tab_name} = socket.assigns
    page = if page + 1 > total_pages, do: total_pages, else: page + 1

    socket
    |> assign_paginate(user.id, tab_name, page)
    |> then(&{:noreply, &1})
  end

  defp icon_base_path(file), do: "/images/common/icons/#{file}"
  defp icon_path(:beginner), do: icon_base_path("jemLow.svg")
  defp icon_path(:normal), do: icon_base_path("jemMiddle.svg")
  defp icon_path(:skilled), do: icon_base_path("jemHigh.svg")

  defp level_text(:beginner), do: "見習い"
  defp level_text(:normal), do: "平均"
  defp level_text(:skilled), do: "ベテラン"
end
