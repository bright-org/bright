defmodule BrightWeb.CardLive.RelatedTeamCardComponent do
  @moduledoc """
  　関わっているチームカードコンポーネント

  - display_user チーム一覧の取得対象となるユーザー
  - over_ride_on_card_row_click_target カードコンポーネント内の行クリック時のハンドラを呼び出し元のハンドラで実装するか否か falseの場合、本実装デフォルトの挙動(チームIDのみ指定してのチームスキル分析への遷移)を実行する

  ## Examples
    <.live_component
      id={@id}
      module={BrightWeb.CardLive.RelatedTeamCardComponent}
      display_user={@display_user}
      over_ride_on_card_row_click_target={:true}
    />
  """
  use BrightWeb, :live_component

  import BrightWeb.TabComponents
  import BrightWeb.TeamComponents
  alias Bright.Teams

  @tabs [
    {"joined_teams", "所属チーム"},
    {"hr_teams", "採用・育成チーム"},
    {"supported_from_teams", "採用・育成支援先"}
  ]

  @menu_items []

  @impl true
  def render(assigns) do
    assigns =
      if assigns.over_ride_on_card_row_click_target == true do
        # オーバーライド指定されている場合は、target指定しない（呼び出し元のハンドラへ返す）
        assign(assigns, :row_on_click_target, nil)
      else
        # オーバーライド指定されていない場合、target指定する(指定がなければ本モジュールのハンドラを実行する)
        assign_new(assigns, :row_on_click_target, fn -> assigns.myself end)
      end

    ~H"""
    <div>
      <.tab
        id={"related-team-card-tab#{@id}"}
        tabs={@tabs}
        selected_tab={@card.selected_tab}
        page={@card.page_params.page}
        total_pages={@card.total_pages}
        menu_items={show_menu(assigns)}
        target={@myself}
      >
        <div class="pt-3 pb-1 px-6 lg:h-[226px]">
          <% # TODO ↓α版対応 %>
          <ul :if={@card.selected_tab != "joined_teams"} class="flex gap-y-2 flex-col">
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
                βリリース（10月予定）で利用可能になります
              </div>
            </li>
          </ul>
          <% # TODO ↑α版対応 %>
          <% # TODO ↓α版対応 @card.selected_tab == "joined_teams" && の条件を削除 %>
        <%= if @card.selected_tab == "joined_teams" && @card.total_entries <= 0 do %>
          <ul class="flex gap-y-2 flex-col">
            <li
            class="flex items-center text-base p-1 rounded">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">所属しているチームはありません</div>
              <a
                 href="/teams/new"
                 class="text-sm font-bold px-5 py-3 rounded text-white bg-base"
               >
                チームを作る（β）
               </a>
            </li>
          </ul>
        <% end %>
        <%= if @card.total_entries > 0 do %>
          <ul class="flex gap-y-2 flex-col">
            <%= for team_member_user <- @card.entries do %>
              <.team_small
                id={team_member_user.team.id}
                team_member_user={team_member_user}
                team_type={:general_team}
                row_on_click_target={assigns.row_on_click_target}
              />
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
    tabs = filter_tabs(@tabs, Map.get(assigns, :display_tabs))
    first_tab = tabs |> Enum.at(0) |> elem(0)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:tabs, tabs)
     |> assign(:card, create_card_param(first_tab))
     |> assign_card(first_tab)
     |> assign(:over_ride_on_card_row_click_target, false)}
  end

  defp filter_tabs(tabs, nil), do: tabs

  defp filter_tabs(tabs, display_tabs) do
    Enum.filter(tabs, fn {key, _} -> key in display_tabs end)
  end

  defp assign_card(socket, "joined_teams") do
    page =
      Teams.list_joined_teams_by_user_id(
        socket.assigns.display_user.id,
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

  defp assign_card(socket, "supported_from_teams") do
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
        %{"id" => _id, "tab_name" => tab_name},
        socket
      ) do
    card_view(socket, tab_name, 1)
  end

  def handle_event(
        "previous_button_click",
        %{"id" => _id},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page - 1
    page = if page < 1, do: 1, else: page

    card_view(socket, card.selected_tab, page)
  end

  def handle_event(
        "next_button_click",
        %{"id" => _id},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page + 1

    page =
      if page > card.total_pages,
        do: card.total_pages,
        else: page

    card_view(socket, card.selected_tab, page)
  end

  @doc """
  パラメータにrow_on_click_targetを指定されなかった場合のチーム行クリック時のデフォルトイベント
  クリックされたチームのチームIDのみを指定して、チームスキル分析に遷移する
  """
  def handle_event("on_card_row_click", %{"team_id" => team_id, "value" => 0}, socket) do
    display_team =
      team_id
      |> Teams.get_team_with_member_users!()

    socket =
      socket
      |> assign(:display_team, display_team)
      |> assign(:display_user, socket.assigns.display_user)
      |> redirect(to: "/teams/#{display_team.id}")

    {:noreply, socket}
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

  defp show_menu(assings) do
    if Map.has_key?(assings, :show_menu) && assings.show_menu == true do
      assings.card.menu_items
    else
      []
    end
  end
end
