defmodule BrightWeb.MyTeamLive do
  @moduledoc """
  チームスキル分析画面
  """
  use BrightWeb, :live_view
  import BrightWeb.ProfileComponents
  import BrightWeb.SkillPanelLive.SkillPanelComponents
  import BrightWeb.ChartLive.SkillGemComponent
  import BrightWeb.DisplayUserHelper
  import BrightWeb.TeamComponents
  import BrightWeb.MegaMenuComponents
  import BrightWeb.BrightModalComponents
  alias Bright.Teams
  alias Bright.Teams.Team
  alias Bright.SkillPanels
  alias Bright.SkillPanels.SkillPanel

  defp get_display_skill_panel(%{"skill_panel_id" => skill_panel_id} = params, _display_team) do
    # TODO チームの誰も保有していないスキルパネルが指定された場合エラーにする必要はないはず

    try do
      SkillPanels.get_skill_panel!(skill_panel_id)
    rescue
      e in Ecto.NoResultsError ->
        # 結果が取得できない場合握りつぶしてnilを返す
        nil
    end
  end

  defp get_display_skill_panel(_params, %Team{} = display_team) do
    # TODO スキルパネルIDが指定されていない場合、チームが取得できていれば第一優先のスキルパネルを取得する

    # キャリアフィールドを問わずチーム内の設定スキルのうち最も新しいスキルパネルを取得
    %{page_number: page, total_pages: total_pages, entries: skill_panels} =
      SkillPanels.list_team_member_users_skill_panels(display_team.id, 1)

    [skill_panels | _tail] = skill_panels
    skill_panels
  end

  defp get_display_skill_panel(_params, _display_team) do
    # TODO スキルパネルIDが指定されていない場合、チームも取得できない場合はnil
    nil
  end

  defp list_display_skill_classes(%SkillPanel{} = skill_panel) do
    SkillPanels.get_all_skill_class_by_skill_panel_id(skill_panel.id)
  end

  defp list_display_skill_classes(skill_panel) do
    nil
  end

  defp get_display_team(%{"team_id" => team_id} = params, user_id) do
    try do
      team = Teams.get_team_with_member_users!(team_id)
      # チームがHITしても自分が所属していない場合は無視する
      iam_member_user =
        team.member_users
        |> Enum.find(fn member_user ->
          member_user.user_id == user_id
        end)

      if iam_member_user == nil do
        nil
      else
        team
      end
    rescue
      e in Ecto.NoResultsError ->
        # 結果が取得できない場合握りつぶしてnilを返す
        nil
    end
  end

  defp get_display_team(_params, user_id) do
    # チームのパラメータが指定されていないログインユーザーの所属するチームを取得
    page = Teams.list_joined_teams_by_user_id(user_id)

    if page.total_entries > 0 do
      # 所属しているチームが存在する場合、第１位優先のチームをディスプレイチームに指定
      [team_member_user] = page.entries
      team_member_user.team
    else
      nil
    end
  end

  defp assign_page_title(socket, %SkillPanel{} = display_skill_panel) do
    socket
    |> assign(:page_title, "チームスキル分析")
    |> assign(:page_sub_title, display_skill_panel.name)
  end

  defp assign_page_title(socket, nil) do
    socket
    |> assign(:page_title, "チームスキル分析")
    |> assign(:page_sub_title, nil)
  end

  defp assign_display_team_and_member_users(socket, %Team{} = display_team) do
    page =
      display_team.id
      |> Teams.list_jined_users_and_skill_unit_scores_by_team_id()

    member_users =
      page.entries
      |> Enum.map(fn team_member_user ->
        team_member_user.user
      end)

    socket
    |> assign(:display_team, display_team)
    |> assign(:member_users, member_users)
  end

  defp assign_display_team_and_member_users(socket, nil) do
    socket
    |> assign(:display_team, nil)
    |> assign(:member_users, [])
  end

  defp assign_display_skill_panel(socket, display_skill_panel) do
    socket
    |> assign(:display_skill_panel, display_skill_panel)
  end

  defp assign_display_skill_class(socket, display_skill_classes) do
    # 表示するスキルクラスが指定されていない場合は最初のクラスを指定
    if !Map.has_key?(socket, :display_skill_class) || socket.assigns.display_skill_class == nil do
      [first_skill_class | later] = display_skill_classes

      socket
      |> assign(:display_skill_classes, display_skill_classes)
      |> assign(:display_skill_class, first_skill_class)
    else
      socket
      |> assign(:display_skill_classes, display_skill_classes)
    end
  end

  # defp assign_push_redirect(socket, %{"team_id" => team_id, "skill_panel_id" => skill_panel_id}, _display_team, _display_skill_panel) do
  defp assign_push_redirect(
         %{assigns: %{live_action: :index}} = socket,
         %{"team_id" => team_id, "skill_panel_id" => skill_panel_id},
         _display_team,
         _display_skill_panel
       ) do
    # パラメータが完全に指定されていた場合、データの取得成否に関わらず、リダイレクトは行わない
    socket
  end

  defp assign_push_redirect(
         %{assigns: %{live_action: :index}} = socket,
         params,
         %Team{} = display_team,
         %SkillPanel{} = display_skill_panel
       ) do
    # パラメータが完全に指定されていない場合、必要なデータが取得できていればパラメータを指定してリダイレクト
    socket
    |> push_redirect(to: "/teams/#{display_team.id}/skill_panels/#{display_skill_panel.id}")
  end

  defp assign_push_redirect(socket, _params, _display_team, _display_skill_panel) do
    # それ以外
    # パラメータが完全に指定されておらず、必要なデータも集められなかった場合
    # リダイレクトはしない
    socket
  end

  def mount(params, _session, socket) do
    # TODO 所属していないチームのチームIDが指定されている場合は404エラー
    # スキルパネルIDはゆるして、ジェム非表示でよいとおもう

    # パラメータ指定がある場合それぞれの対象データを取得、ない場合はnil
    display_team = get_display_team(params, socket.assigns.current_user.id)
    display_skill_panel = get_display_skill_panel(params, display_team)
    display_skill_classes = list_display_skill_classes(display_skill_panel)

    # スキルとチームの取得結果に応じて各種assign
    socket =
      socket
      |> assign_page_title(display_skill_panel)
      |> assign_display_team_and_member_users(display_team)
      |> assign_display_skill_panel(display_skill_panel)
      |> assign_display_skill_class(display_skill_classes)
      # パラメータの指定内容とデータの取得結果によってリダイレクトを指定
      |> assign_push_redirect(params, display_team, display_skill_panel)

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
      # |> assign(:page_title, "チームスキル分析 / #{display_skill_panel.name}")
      |> push_redirect(
        to: "/teams/#{socket.assigns.display_team.id}/skill_panels/#{skill_panel_id}"
      )

    {:noreply, socket}
  end
end
