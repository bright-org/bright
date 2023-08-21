defmodule BrightWeb.CardLive.RelatedTeamCardComponent do
  @moduledoc """
  　関わっているチームカードコンポーネント

  - current_user チーム一覧の取得対象となるユーザー
  - over_ride_on_card_row_click_target カードコンポーネント内の行クリック時のハンドラを呼び出し元のハンドラで実装するか否か falseの場合、本実装デフォルトの挙動(チームIDのみ指定してのチームスキル分析への遷移)を実行する

  ## Examples
    <.live_component
      id={@id}
      module={BrightWeb.CardLive.RelatedTeamCardComponent}
      current_user={@current_user}
      over_ride_on_card_row_click_target={:true}
    />
  """
  use BrightWeb, :live_component

  import BrightWeb.TabComponents
  import BrightWeb.TeamComponents
  alias Bright.Teams

  @tabs [
    {"joined_teams", "所属チーム"}
    # TODO αリリース対象外 {"hr_teams", "人材チーム"},
    # TODO αリリース対象外 {"suppored_from_teams", "人材支援されているチーム(仮)"}
  ]

  @menu_items []

  @impl true
  def render(assigns) do
    assigns =
      if Map.has_key?(assigns, :over_ride_on_card_row_click_target) &&
           assigns.over_ride_on_card_row_click_target == true do
        # オーバーライド指定されている場合は、target指定しない（呼び出し元のハンドラへ返す）
        assigns
        |> assign(:low_on_click_target, nil)
      else
        # オーバーライド指定されていいない場合、target指定する(本実装のハンドラを実行する)
        assigns
        |> assign(:low_on_click_target, assigns.myself)
      end

    ~H"""
    <div>
      <.tab
        id={"related_team_card_tab#{@id}"}
        tabs={@tabs}
        selected_tab={@card.selected_tab}
        page={@card.page_params.page}
        total_pages={@card.total_pages}
        menu_items={show_menu(assigns)}
        target={@myself}
      >
        <div class="pt-3 pb-1 px-6">
        <%= if @card.total_entries <= 0 do %>
          <ul class="flex gap-y-2.5 flex-col">
            <li
            class="flex items-center text-base p-1 rounded">
              <p class="w-full align-middle">所属しているチームはありません。</p>
            </li>
            <%= for _blank <- 0.. @card.page_params.page_size - 1 do %>
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
              <.team_small
                id="team_small_#{team.id}"
                team={team.team}
                team_type={:general_team}
                low_on_click_target={assigns.low_on_click_target}
              />
            <% end %>
            <%= for _blank <- 0.. @card.page_params.page_size - length(@card.entries) do %>
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
  パラメータにlow_on_click_targetを指定されなかった場合のチーム行クリック時のデフォルトイベント
  クリックされたチームのチームIDのみを指定して、チームスキル分析に遷移する
  """
  def handle_event("on_card_row_click", %{"team_id" => team_id, "value" => 0}, socket) do
    current_team =
      team_id
      |> Teams.get_team_with_member_users!()

    socket =
      socket
      |> assign(:current_team, current_team)
      |> assign(:current_user, socket.assigns.current_user)
      |> push_navigate(to: "/teams/#{current_team.id}")

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
