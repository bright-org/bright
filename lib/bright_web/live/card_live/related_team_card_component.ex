defmodule BrightWeb.CardLive.RelatedTeamCardComponent do
  @moduledoc """
  　関わっているチームカードコンポーネント
  """
  use BrightWeb, :live_component

  import BrightWeb.TabComponents
  import BrightWeb.CardLive.CardListComponents
  import BrightWeb.TeamComponents
  alias Bright.Teams

  @tabs [
    {"joined_teams", "所属チーム"},
    {"hr_teams", "人材チーム"},
    {"suppored_from_teams", "人材支援されているチーム(仮)"}
  ]

  @menu_items [
    %{text: "チームを作る", on_click: show_modal("create-team-modal")},
    %{text: "人材チームへのチーム登録依頼", href: "/"},
    %{text: "管理チームの編集", href: "/"},
    %{text: "管理チームの削除", href: "/"}
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.tab
        id="related_team_card"
        tabs={@tabs}
        selected_tab={@card.selected_tab}
        page={@card.page_params.page}
        total_pages={@card.total_pages}
        menu_items={show_menue(assigns)}
        target={@myself}
      >
        <div class="pt-3 pb-1 px-6">
        <%= if @card.total_entries <= 0 do %>
          <ul class="flex gap-y-2.5 flex-col">
            <li
            class="flex items-center text-base p-1 rounded">
              <p class="w-full align-middle">所属しているチームはありません。</p>
            </li>
            <%= for blank <- 0.. @card.page_params.page_size - 1 do %>
              <li
              class="flex items-center text-base p-1 rounded">
                <br/>
              </li>
            <% end %>
          </ul>
        <% end %>
        <%= if @card.total_entries > 0 do %>
          <ul class="flex gap-y-2.5 flex-col">
            <%= for team <- @card.entries do %>
              <.team_small team={team.team} team_type={:general_team} />
            <% end %>
            <%= for blank <- 0.. @card.page_params.page_size - length(@card.entries) do %>
              <li
              class="flex items-center text-base p-1 rounded">
                <br/>
              </li>
            <% end %>
          </ul>
        <% end %>
        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:tabs, @tabs)
     |> assign(:card, create_card_param("joined_teams"))
     |> assign_card("joined_teams")}
  end

  defp assign_card(socket, "joined_teams") do
    page =
      Teams.list_joined_teams_by_user_id(
        socket.assigns.current_user.id,
        socket.assigns.card.page_params
      )

    card = %{
      socket.assigns.card
      | entries: page.entries,
        total_entries: page.total_entries,
        total_pages: page.total_pages
    }

    socket
    |> assign(:card, card)
  end

  defp assign_card(socket, "hr_teams") do
    # TODO タブごとのteamをとってくる処理

    card = %{
      socket.assigns.card
      | entries: [],
        total_pages: 0
    }

    socket
    |> assign(:card, card)
  end

  defp assign_card(socket, "suppored_from_teams") do
    # TODO タブごとのteamをとってくる処理

    card = %{
      socket.assigns.card
      | entries: [],
        total_pages: 0
    }

    socket
    |> assign(:card, card)
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => "related_team_card", "tab_name" => tab_name},
        socket
      ) do
    card_view(socket, tab_name, 1)
  end

  def handle_event(
        "previous_button_click",
        %{"id" => "related_team_card"},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page - 1
    page = if page < 1, do: 1, else: page
    card_view(socket, card.selected_tab, page)
  end

  def handle_event(
        "next_button_click",
        %{"id" => "related_team_card"},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page + 1

    page =
      if page > card.total_pages,
        do: card.total_pages,
        else: page

    card_view(socket, card.selected_tab, page)
  end

  defp card_view(socket, tab_name, page) do
    card = create_card_param(tab_name, page)

    socket
    |> assign(:card, card)
    |> assign_card(tab_name)
    |> then(&{:noreply, &1})
  end

  defp create_card_param(selected_tab, page \\ 1) do
    %{
      selected_tab: selected_tab,
      entries: [],
      page_params: %{page: page, page_size: 5},
      total_entries: 0,
      total_pages: 0,
      menu_items: @menu_items
    }
  end

  @doc """
    TabComponentのタブメニュー表示制御
  """
  defp show_menue(assings) do
    if Map.has_key?(assings, :show_menue) && assings.show_menue == true do
      assings.card.menu_items
    else
      []
    end
  end
end
