defmodule BrightWeb.MyTeamLive do
  @moduledoc """
  チームスキル分析画面
  """
  use BrightWeb, :live_view
  import BrightWeb.ProfileComponents
  import BrightWeb.SkillPanelLive.SkillPanelComponents
  import BrightWeb.DisplayUserHelper
  import BrightWeb.TeamComponents
  import BrightWeb.MegaMenuComponents
  import BrightWeb.BrightModalComponents
  alias Bright.Teams
  alias Bright.SkillPanels


  def mount(%{live_action: :index} = params, _session, socket) do

    IO.puts("#### mount ###########################")

    socket =
    if Map.has_key?(params, "skill_panel_id") do
      IO.puts("#### skill_panel_id exist !!!!!!!!!!!!!!!!!")
      display_skill_panel = params
      |> Map.get("skill_panel_id")
      |> SkillPanels.get_skill_panel!()

      IO.inspect(display_skill_panel)

      socket
      # TODO display_skill_panel
      |> assign(:page_title, "チームスキル分析")
      |> assign(:page_sub_title, display_skill_panel.name)
      |> assign(:display_skill_panel, display_skill_panel)
    else
      IO.puts("#### skill_panel_id none !!!!!!!!!!!!!!!!!")
      socket
      # TODO current_skill_panelから取得する
      |> assign(:page_title, "チームスキル分析")
      |> assign(:page_sub_title, nil)
    end

    if Map.has_key?(params, "team_id") do
      display_team =
        params
        |> Map.get("team_id")
        |> Teams.get_team_with_member_users!()

      page =
        display_team.id
        |> Teams.list_jined_users_and_skill_unit_scores_by_team_id()

      member_users =
        page.entries
        |> Enum.map(fn team_member_user ->
          team_member_user.user
        end)

      socket =
        socket
        |> assign(:display_team, display_team)
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
          |> assign(:display_team, team_member_user.team)
          |> assign(:current_user, socket.assigns.current_user)
          |> push_navigate(to: "/teams/#{team_member_user.team.id}")
        else
          # 所属しているチームが存在しない場合、チーム表示なしの空のページを表示する
          socket
          |> assign(:display_team, nil)
          |> assign(:current_user, socket.assigns.current_user)
          |> assign(:member_users, [])
        end

      {:ok, socket}
    end
  end

  def mount(params, _session, socket) do
    socket = socket
          |> assign(:display_team, nil)
          |> assign(:current_user, socket.assigns.current_user)
          |> assign(:member_users, [])
    {:ok, socket}
  end

  @doc """
  メガメニューのチームカードからチームの行をクリックした場合のハンドラー

  display_teamを選択したチームのチームIDで更新し、リダイレクトする。
  その際、選択済のスキルパネル、またはスキルセットがある場合IDを引き継ぐ
  """
  def handle_event("on_card_row_click", %{"team_id" => team_id}, socket) do
    display_team = Teams.get_team_with_member_users!(team_id)

    socket =
      socket
      |> assign(:display_team, display_team)
      |> push_redirect(to: "/teams/#{display_team.id}")

    {:noreply, socket}
  end

  def handle_event("on_skill_pannel_click", %{"skill_panel_id" => skill_panel_id}, socket) do

    IO.puts("### handle_event on_skill_pannel_click !!!!!!!!!!!!!!!!!!!!!!!")

    display_skill_panel = SkillPanels.get_skill_panel!(skill_panel_id)

    socket =
      socket
      |> assign(:display_skill_panel, display_skill_panel)
      #|> assign(:page_title, "チームスキル分析 / #{display_skill_panel.name}")
      |> push_redirect(to: "/teams/#{socket.assigns.display_team.id}/skill_panels/#{skill_panel_id}")

    {:noreply, socket}
  end
end
