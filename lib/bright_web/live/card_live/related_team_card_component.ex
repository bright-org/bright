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
  alias Bright.CustomGroups

  @tabs [
    {"joined_teams", "所属チーム"},
    {"supporter_teams", "採用・育成チーム"},
    {"supportee_teams", "採用・育成支援先"},
    {"custom_groups", "カスタムグループ"}
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
          <ul :if={@card.selected_tab == "supporter_teams" and @card.total_entries == 0}
            class="flex gap-y-2 flex-col">
            <li class="flex items-center text-base p-1 rounded">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">支援を受けている採用・育成チームはありません</div>
              <a class="text-sm font-bold px-5 py-3 rounded text-white bg-brightGray-200">
                採用・育成チームに支援してもらう（β）
              </a>
            </li>
            βリリース（11月予定）で利用可能になります
          </ul>
          <ul :if={@card.selected_tab == "supportee_teams" and @card.total_entries == 0}
            class="flex gap-y-2 flex-col">
            <li class="flex items-center text-base p-1 rounded">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">支援中の採用・育成先チームはありません</div>
                <a href="https://bright-fun.org/plan" class="w-[calc(45%-6px)] lg:w-56" rel="noopener noreferrer" target="_blank">
                  <button type="button" class="text-white bg-planUpgrade-600 px-1 inline-flex justify-center rounded-md text-xs items-center font-bold h-9 w-full hover:opacity-70 lg:px-2 lg:text-sm">
                    <span class="bg-white material-icons mr-1 !text-sm !text-planUpgrade-600 rounded-full h-5 w-5 !font-bold material-icons-outlined lg:mr-2 lg:h-6 lg:w-6">upgrade</span>
                    アップグレード
                  </button>
                </a>
            </li>
          </ul>
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
            <%= for team_params <- @card.entries do %>
              <.team_small
                id={team_params.team_id}
                team_params={team_params}
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
     |> assign(:over_ride_on_card_row_click_target, false)
     |> assign(assigns)
     |> assign(:tabs, tabs)
     |> assign(:card, create_card_param(first_tab))
     |> assign_card(first_tab)}
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

    team_params =
      page.entries
      |> convert_team_params_from_team_member_users()

    card = %{
      socket.assigns.card
      | entries: team_params,
        total_entries: page.total_entries,
        total_pages: page.total_pages
    }

    socket
    |> assign(:card, card)
  end

  defp assign_card(socket, "supportee_teams") do
    page =
      Teams.list_supportee_teams_by_supporter_user_id(
        socket.assigns.display_user.id,
        socket.assigns.card.page_params
      )

    team_params =
      page.entries
      |> convert_team_params_from_teams()

    card = %{
      socket.assigns.card
      | entries: team_params,
        total_entries: page.total_entries,
        total_pages: page.total_pages
    }

    socket
    |> assign(:card, card)
  end

  defp assign_card(socket, "supporter_teams") do
    page =
      Teams.list_supporter_teams_by_supportee_user_id(
        socket.assigns.display_user.id,
        socket.assigns.card.page_params
      )

    team_params =
      page.entries
      |> convert_team_params_from_teams()

    card = %{
      socket.assigns.card
      | entries: team_params,
        total_entries: page.total_entries,
        total_pages: page.total_pages
    }

    socket
    |> assign(:card, card)
  end

  defp assign_card(socket, "custom_groups") do
    page =
      CustomGroups.list_user_custom_groups(
        socket.assigns.display_user.id,
        socket.assigns.card.page_params
      )

    team_params =
      page.entries
      |> convert_team_params_from_custom_groups()

    card = %{
      socket.assigns.card
      | entries: team_params,
        total_entries: page.total_entries,
        total_pages: page.total_pages
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
  def handle_event("on_card_row_click", params, socket) do
    {:noreply, redirect(socket, to: "/teams/#{params["team_id"]}")}
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

  defp convert_team_params_from_team_member_users(team_member_users) do
    team_member_users
    |> Enum.map(fn team_member_user ->
      %{
        team_id: team_member_user.team.id,
        name: team_member_user.team.name,
        is_star: team_member_user.is_star,
        is_admin: team_member_user.is_admin,
        team_type: Teams.get_team_type_by_team(team_member_user.team)
      }
    end)
  end

  defp convert_team_params_from_teams(teams) do
    teams
    |> Enum.map(fn team ->
      %{
        team_id: team.id,
        name: team.name,
        is_star: nil,
        is_admin: nil,
        team_type: Teams.get_team_type_by_team(team)
      }
    end)
  end

  defp convert_team_params_from_custom_groups(custom_groups) do
    custom_groups
    |> Enum.map(fn custom_group ->
      %{
        team_id: custom_group.id,
        name: custom_group.name,
        is_star: nil,
        is_admin: nil,
        team_type: :custom_group
      }
    end)
  end
end
