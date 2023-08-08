# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.SkillCardComponent do
  @moduledoc """
  Skill Card Component
  """
  use BrightWeb, :live_component
  import BrightWeb.TabComponents
  alias Bright.UserSkillPanels

  # TODO selected_tab,selected_tab,page,total_pagesは未実装でダミーです
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.tab
        id="skill_card"
        selected_tab={@card.selected_tab}
        page={@card.page_params.page}
        total_pages={@card.total_pages}
        target={@myself}
        tabs={@tabs}
      >
        <div class="py-6 px-7 flex gap-y-4 flex-col min-h-[464px]">
          <ul :if={Enum.count(@card.skill_panels) == 0} class="flex gap-y-2.5 flex-col">
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
              <%= Enum.into(@tabs, %{}) |> Map.get(@card.selected_tab) %>はありません
              </div>
            </li>
          </ul>
          <div :if={Enum.count(@card.skill_panels) > 0} class="flex">
            <div class="flex-1 text-left font-bold"></div>
            <div class="w-36 font-bold">クラス1</div>
            <div class="w-36 font-bold">クラス2</div>
            <div class="w-36 font-bold">クラス3</div>
          </div>
          <%= for skill_panel <- @card.skill_panels do %>
            <.skill_panel skill_panel={skill_panel} />
          <% end %>
        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    tabs =
      Bright.Jobs.list_career_fields()
      |> Enum.map(&{&1.name_en, &1.name_ja})

    {:ok, assign(socket, :tabs, tabs)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:card, create_card_param("engineer"))
     |> assign_card()}
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => "skill_card", "tab_name" => tab_name},
        socket
      ) do
    card_view(socket, tab_name, 1)
  end

  def handle_event(
        "previous_button_click",
        %{"id" => "skill_card"},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page - 1
    page = if page < 1, do: 1, else: page
    card_view(socket, card.selected_tab, page)
  end

  def handle_event(
        "next_button_click",
        %{"id" => "skill_card"},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page + 1

    page =
      if page > card.total_pages,
        do: card.total_pages,
        else: page

    card_view(socket, card.selected_tab, page)
  end


  defp skill_panel(assigns) do
    ~H"""
    <div class="flex">
      <div class="flex-1 text-left font-bold">
        <.link
          href={~p"/panels/#{@skill_panel.id}/graph"}
          method="get"
        >
          <%= @skill_panel.name %>
        </.link>
      </div>
      <%= for {level, class} <- Enum.with_index(@skill_panel.levels, 1) do %>
        <.skill_gem level={level} class={class} id={@skill_panel.id}/>
      <% end %>
    </div>
    """
  end

  defp skill_gem(%{level: :none} = assigns) do
    ~H"""
    <div class="w-36"></div>
    """
  end

  defp skill_gem(assigns) do
    assigns =
      assigns
      |> assign(:icon_path, icon_path(assigns.level))

    ~H"""
    <div class="w-36">
      <.link
        href={~p"/panels/#{@id}/graph?class=#{@class}"}
        method="get"
      >
        <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
          <img src={@icon_path} class="mr-1" /><%= level_text(@level) %>
        </p>
      </.link>
    </div>
    """
  end

  defp icon_base_path(file), do: "/images/common/icons/#{file}"
  defp icon_path(:beginner), do: icon_base_path("jemLow.svg")
  defp icon_path(:normal), do: icon_base_path("jemMiddle.svg")
  defp icon_path(:skilled), do: icon_base_path("jemHigh.svg")

  defp level_text(:beginner), do: "見習い"
  defp level_text(:normal), do: "平均"
  defp level_text(:skilled), do: "ベテラン"

  defp card_view(socket, tab_name, page) do
    card = create_card_param(tab_name, page)

    socket
    |> assign(:card, card)
    |> assign_card()
    |> then(&{:noreply, &1})
  end

  defp create_card_param(selected_tab, page \\ 1) do
    %{
      selected_tab: selected_tab,
      skill_panels: [],
      page_params: %{page: page, page_size: 15},
      total_pages: 0
    }
  end

  defp assign_card(%{assigns: %{current_user: user, card: card}} = socket) do

      skill_panels = UserSkillPanels.get_level_by_class_in_skills_panel(user.id, card.page_params)
      |> IO.inspect()

    card = %{
      card
      | skill_panels: skill_panels.entries,
        total_pages: skill_panels.total_pages / 3
    }

    socket
    |> assign(:card, card)
  end

end
