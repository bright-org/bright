# TODO 「報酬アップを相談」リファクタリングすること
defmodule BrightWeb.CardLive.RemunerationConsultationComponent do
  @moduledoc """
  　関わっているチームカードコンポーネント

  - display_user チーム一覧の取得対象となるユーザー. 匿名考慮がされていないため原則current_user
  - over_ride_on_card_row_click_target カードコンポーネント内の行クリック時のハンドラを呼び出し元のハンドラで実装するか否か falseの場合、本実装デフォルトの挙動(チームIDのみ指定してのチームスキル分析への遷移)を実行する

  ## Examples
    <.live_component
      id={@id}
      module={BrightWeb.CardLive.RelatedTeamCardComponent}
      display_user={@current_user}
      over_ride_on_card_row_click_target={:true}
    />
  """
  use BrightWeb, :live_component

  import BrightWeb.TeamComponents

  alias Bright.Teams

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

        <div class="pt-3 pb-1 px-6 lg:h-[226px]">
          <%= if @card.total_entries > 0 do %>
            <ul class="flex gap-y-2 flex-col">
              <%= for team_params <- @card.entries do %>
                <.team_small_admin
                  id={team_params.team_id}
                  team_params={team_params}
                  row_on_click_target={assigns.row_on_click_target}
                />
              <% end %>
            </ul>
          <% else %>
            <% # 表示内容がないときの表示 %>
            <ul>
            </ul>
          <% end %>
        </div>
       </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:over_ride_on_card_row_click_target, false)
     |> assign(assigns)
     |> assign(:card, create_card_param("joined_teams"))
     |> assign_card("joined_teams")}
  end

  defp assign_card(socket, "joined_teams") do
    %{display_user: display_user, card: card} = socket.assigns

    page = Teams.list_joined_teams_by_user_id2(display_user.id, card.page_params)
    free_trial_together_link? = show_free_trial_together_link?(display_user)

    team_params =
      page.entries
      |> convert_team_params_from_team_member_users2()
      |> Enum.map(&Map.put(&1, :free_trial_together_link?, free_trial_together_link?))

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
end
