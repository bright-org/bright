defmodule BrightWeb.CardLive.ManagingTeamCardComponent do
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
    {"managing_teams", "招待可能なチーム"}
  ]

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
        id={"managing-team-card-tab#{@id}"}
        tabs={@tabs}
        selected_tab={@card.selected_tab}
        page={@card.page_params.page}
        total_pages={@card.total_pages}
        target={@myself}
      >
        <div class="pt-3 pb-1 px-6 lg:h-[226px]">
          <%= if @card.total_entries > 0 do %>
            <ul class="flex gap-y-2 flex-col">
              <%= for team_params <- @card.entries do %>
                <div class={if team_params.team_id == @team_id, do: "bg-brightGray-50", else: ""}>
                  <li
                    id={team_params.team_id}
                    phx-click="on_card_row_click"
                    phx-target={@myself}
                    phx-value-team_id={team_params.team_id}
                    class="h-[35px] text-left flex items-center text-base p-1 rounded cursor-pointer"
                  >
                    <img src={get_team_icon_path(team_params.team_type)} class="ml-2 mr-2" />
                    <span class="max-w-[160px] lg:max-w-[540px] truncate"><%= team_params.name %></span>
                  </li>
                </div>
              <% end %>
            </ul>
          <% else %>
            <% # 表示内容がないときの表示 %>
            <ul>
              <li :if={@card.selected_tab == "joined_teams"} class="text-base text-left p-1">
                <div class="text-base">招待可能なチームはありません</div>
                <p class="my-4">
                  <a href="/teams/new" class="text-sm font-bold px-5 py-3 rounded text-white bg-base">
                    チームを作る
                  </a>
                </p>
              </li>
            </ul>
          <% end %>
        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    first_tab = @tabs |> Enum.at(0) |> elem(0)

    {:ok,
     socket
     |> assign(:over_ride_on_card_row_click_target, false)
     |> assign(assigns)
     |> assign(:tabs, @tabs)
     |> assign(:card, create_card_param(first_tab))
     |> assign(:team_id, nil)
     |> assign_card(first_tab)}
  end

  defp assign_card(socket, "managing_teams") do
    page =
      Teams.list_managing_teams_by_user_id(
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
  def handle_event("on_card_row_click", %{"team_id" => team_id}, socket) do
    send_update(BrightWeb.RecruitEmploymentLive.TeamInviteComponent,
      id: "team_join_modal",
      team_id: team_id
    )

    {:noreply, assign(socket, :team_id, team_id)}
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
      total_pages: 0
    }
  end
end
