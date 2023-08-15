defmodule BrightWeb.MyTeamLive do
  @moduledoc """
  チームスキル分析画面
  """
  use BrightWeb, :live_view
  import BrightWeb.ProfileComponents
  import BrightWeb.MegaMenuComponents
  import BrightWeb.BrightModalComponents
  alias Bright.Teams

  def mount(params, _session, socket) do
    socket =
      socket
      # TODO current_skill_panelから取得する
      |> assign(:page_title, "チームスキル分析 / ElixirWeb開発")

    if Map.has_key?(params, "team_id") do
      current_team =
        params
        |> Map.get("team_id")
        |> Teams.get_team!()

      page =
        current_team.id
        |> Teams.list_jined_users_and_skill_unit_scores_by_team_id()

      member_users =
        page.entries
        |> Enum.map(fn team_member_user ->
          team_member_user.user
        end)

      socket =
        socket
        |> assign(:current_team, current_team)
        |> assign(:current_user, socket.assigns.current_user)
        |> assign(:member_users, member_users)

      {:ok, socket}
    else
      # チームIDが指定されていない場合、所属しているチームを検索
      page = Teams.list_joined_teams_by_user_id(socket.assigns.current_user.id)

      socket =
        if page.total_entries > 0 do
          # 所属しているチームが存在する場合、第１位優先のチームID指定でリダイレクト
          [team_member_user] = page.entries

          socket
          |> assign(:current_team, team_member_user.team)
          |> assign(:current_user, socket.assigns.current_user)
          |> push_navigate(to: "/teams/#{team_member_user.team.id}")
        else
          # 所属しているチームが存在しない場合、チーム表示なしの空のページを表示する
          socket
          |> assign(:current_team, nil)
          |> assign(:current_user, socket.assigns.current_user)
          |> assign(:member_users, [])
        end

      {:ok, socket}
    end
  end

  @doc """
  メガメニューのチームカードからチームの行をクリックした場合のハンドラー

  current_teamを選択したチームのチームIDで更新し、リダイレクトする。
  その際、選択済のスキルパネル、またはスキルセットがある場合IDを引き継ぐ
  """
  def handle_event("on_card_row_click", %{"team_id" => team_id, "value" => 0}, socket) do
    # TODO IO.puts("#### my_team_live handle_event !!!!!!!!! ###########")

    current_team =
      team_id
      |> Teams.get_team!()

    socket =
      socket
      |> assign(:current_team, current_team)
      |> assign(:current_user, socket.assigns.current_user)
      |> push_navigate(to: "/teams/#{current_team.id}")

    {:noreply, socket}
  end
end
