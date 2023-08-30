# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.SkillCardComponent do
  @moduledoc """
  Skill Card Component
  """
  use BrightWeb, :live_component
  import BrightWeb.TabComponents
  alias Bright.{CareerFields, SkillPanels}
  alias BrightWeb.PathHelper

  @impl true
  def render(assigns) do
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
        <div class="py-6 px-7 flex gap-y-4 flex-col min-h-[464px]">
          <ul :if={Enum.count(@skill_panels) == 0} class="flex gap-y-2.5 flex-col">
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
              <%= Enum.into(@tabs, %{}) |> Map.get(@selected_tab) %>はありません
              </div>
            </li>
          </ul>
          <div :if={Enum.count(@skill_panels) > 0} class="flex">
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
            />
          <% end %>
        </div>
      </.tab>
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
    <div class="flex">
      <div class="flex-1 text-left font-bold">
        <.link href={PathHelper.skill_panel_path(@root, @skill_panel, @display_user, @me, @anonymous)}>
          <%= @skill_panel.name %>
        </.link>
      </div>
      <%= for class <- @skill_classes do %>
        <.skill_gem
          score={List.first(class.skill_class_scores)}
          class_num={class.class}
          skill_panel={@skill_panel}
          display_user={@display_user}
          me={@me}
          anonymous={@anonymous}
          root={@root}
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
    <div class="w-36"></div>
    """
  end

  defp skill_gem(%{score: %{level: level}} = assigns) do
    assigns =
      assigns
      |> assign(:icon_path, icon_path(level))
      |> assign(:level, level)

    ~H"""
    <div class="w-36">
      <.link href={PathHelper.skill_panel_path(@root, @skill_panel, @display_user, @me, @anonymous) <> "?class=#{@class_num}"}>
        <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
          <img src={@icon_path} class="mr-1" />
          <span class="w-16"><%= level_text(@level) %></span>
        </p>
      </.link>
    </div>
    """
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

  def update(%{status: "level_up"}, socket) do
    # 新しいスキルクラスを開放時のupdateを実施
    %{
      selected_tab: career_field,
      display_user: display_user,
      page: page
    } = socket.assigns

    {:ok, assign_paginate(socket, display_user.id, career_field, page)}
  end

  def assign_paginate(socket, user_id, career_field, page \\ 1) do
    %{page_number: page, total_pages: total_pages, entries: skill_panels} =
      SkillPanels.list_users_skill_panels_by_career_field(user_id, career_field, page)

    socket
    |> assign(:skill_panels, skill_panels)
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
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
        %{assigns: %{page: page, selected_tab: tab_name, display_user: user}} = socket
      ) do
    page = if page - 1 < 1, do: 1, else: page - 1

    socket
    |> assign_paginate(user.id, tab_name, page)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "next_button_click",
        _params,
        %{
          assigns: %{
            page: page,
            total_pages: total_pages,
            selected_tab: tab_name,
            display_user: user
          }
        } = socket
      ) do
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
