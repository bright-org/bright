defmodule BrightWeb.TeamLive.MyTeamHelper do
  @moduledoc """
  チームの表示に関するモジュール
  """
  import Phoenix.Component, only: [assign: 3]
  import Phoenix.LiveView, only: [push_navigate: 2]

  alias Bright.Teams
  alias Bright.Teams.Team
  alias Bright.SkillPanels
  alias Bright.SkillPanels.SkillPanel
  alias BrightWeb.SkillPanelLive.SkillPanelHelper

  def init_assign(params, %{assigns: %{live_action: :new}} = socket) do
    # 直接チーム作成モーダルを起動した場合、データの取得は行わない
    socket
    |> assign_page_title(nil)
    |> assign_display_skill_panel(nil)
    |> assign_display_skill_classes([])
    |> assign_display_team(nil)
    |> assign_current_users_team_member(nil)
    # ユーザー事に表示するスキルカードのmap作成とassign
    |> assign_display_skill_cards(
      [],
      [],
      nil,
      []
    )
    # パラメータの指定内容とデータの取得結果によってリダイレクトを指定
    |> assign_push_redirect(params, nil, nil)
  end

  def init_assign(params, socket) do
    # パラメータ指定がある場合それぞれの対象データを取得、ない場合はnil
    display_team = get_display_team(params, socket.assigns.current_user.id)
    # TODO チームスキルカードのページング処理
    display_team_members = get_display_team_members(display_team)

    current_users_team_member =
      get_current_users_team_member(socket.assigns.current_user, display_team_members)

    display_skill_panel = get_display_skill_panel(params, display_team)
    display_skill_classes = list_display_skill_classes(display_skill_panel)
    selected_skill_class = get_selected_skill_class(params, display_skill_classes)
    member_skill_classes = list_skill_classes(display_team, display_skill_panel)

    # スキルとチームの取得結果に応じて各種assign
    socket
    |> assign_page_title(display_skill_panel)
    |> assign_display_skill_panel(display_skill_panel)
    |> assign_display_skill_classes(display_skill_classes)
    |> assign_display_team(display_team)
    |> assign_current_users_team_member(current_users_team_member)
    # ユーザー事に表示するスキルカードのmap作成とassign
    |> assign_display_skill_cards(
      display_team_members,
      display_skill_classes,
      selected_skill_class,
      member_skill_classes
    )
    # パラメータの指定内容とデータの取得結果によってリダイレクトを指定
    |> assign_push_redirect(params, display_team, display_skill_panel)
  end

  defp get_display_skill_panel(%{"skill_panel_id" => skill_panel_id}, _display_team) do
    # TODO チームの誰も保有していないスキルパネルが指定された場合エラーにする必要はないはず

    try do
      SkillPanelHelper.raise_if_not_ulid(skill_panel_id)
      SkillPanels.get_skill_panel!(skill_panel_id)
    rescue
      _e in Ecto.NoResultsError ->
        # 結果が取得できない場合握りつぶしてnilを返す
        nil
    end
  end

  defp get_display_skill_panel(_params, %Team{} = display_team) do
    # TODO スキルパネルIDが指定されていない場合、チームが取得できていれば第一優先のスキルパネルを取得する

    # キャリアフィールドを問わずチーム内の設定スキルのうち最も新しいスキルパネルを取得
    %{page_number: _page, total_pages: _total_pages, entries: skill_panels} =
      SkillPanels.list_team_member_users_skill_panels(display_team.id, 1)

    List.first(skill_panels)
  end

  defp get_display_skill_panel(_params, _display_team) do
    # TODO スキルパネルIDが指定されていない場合、チームも取得できない場合はnil
    nil
  end

  defp list_display_skill_classes(%SkillPanel{} = skill_panel) do
    SkillPanels.get_all_skill_classes_by_skill_panel_id(skill_panel.id)
  end

  defp list_display_skill_classes(_skill_panel) do
    # スキルパネルが取得できていない場合、スキルクラスを取得しない
    []
  end

  defp get_display_team(%{"team_id" => team_id}, user_id) do
    try do
      Teams.raise_if_not_ulid(team_id)

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
      _e in Ecto.NoResultsError ->
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

  defp assign_display_team(socket, display_team) do
    socket
    |> assign(:display_team, display_team)
  end

  defp assign_display_skill_cards(
         socket,
         [],
         _display_skill_classes,
         nil,
         _member_skill_classes
       ) do
    # チームメンバーが取得できていない場合、スキルカードは空表示
    socket
    |> assign(:display_skill_cards, [])
    |> assign(:select_skill_class, nil)
  end

  defp assign_display_skill_cards(
         socket,
         team_member_users,
         [],
         nil,
         _member_skill_classes
       ) do
    # チームメンバーは存在するが、スキルが取得できていない場合
    display_member_for_skill_card =
      team_member_users
      |> Enum.map(fn member ->
        # カードにはダミーのスコアを設定
        %{user: member.user}
        |> add_user_skill_class_score([], [])
        |> add_select_skill_class(nil)
      end)

    socket
    |> assign(:display_skill_cards, display_member_for_skill_card)
  end

  defp assign_display_skill_cards(
         socket,
         team_member_users,
         display_skill_classes,
         first_skill_class,
         member_skill_classes
       ) do
    display_member_for_skill_card =
      team_member_users
      |> Enum.map(fn member ->
        # ユーザー毎に該当ユーザーのスキルクラススコアが取得出来ているか検索
        filterd_member_skill_classes =
          member_skill_classes
          |> Enum.filter(fn member_skill_class ->
            member_skill_class.user_id == member.user.id
          end)

        %{user: member.user}
        |> add_user_skill_class_score(display_skill_classes, filterd_member_skill_classes)
        |> add_select_skill_class(first_skill_class)
      end)

    socket
    |> assign(:display_skill_cards, display_member_for_skill_card)
  end

  defp add_select_skill_class(map, select_skill_class) do
    map
    |> Map.put_new(:select_skill_class, select_skill_class)
  end

  defp add_user_skill_class_score(map, _display_skill_classes, []) do
    # スキルが取得できていない場合、ダミーデータを設定
    map
    |> Map.put(:user_skill_class_score, nil)
  end

  defp add_user_skill_class_score(map, display_skill_classes, filterd_member_skill_classes) do
    # display_skill_classesに対応する該当ユーザーのスキルクラススコアが存在するかチェック
    # 存在しない場合はnilを設定する
    user_skill_class_score =
      display_skill_classes
      |> Enum.map(fn display_skill_class ->
        skill_class_score =
          filterd_member_skill_classes
          |> Enum.find(fn filterd_member_skill_class ->
            filterd_member_skill_class.skill_class_id == display_skill_class.id
          end)

        %{
          skill_class: display_skill_class,
          skill_class_score: skill_class_score
        }
      end)

    map
    |> Map.put(:user_skill_class_score, user_skill_class_score)
  end

  defp assign_display_skill_panel(socket, display_skill_panel) do
    socket
    |> assign(:display_skill_panel, display_skill_panel)
  end

  defp assign_display_skill_classes(socket, []) do
    socket
    |> assign(:display_skill_classes, [])
  end

  defp assign_display_skill_classes(socket, display_skill_classes) do
    socket
    |> assign(:display_skill_classes, display_skill_classes)
  end

  defp assign_push_redirect(
         %{assigns: %{live_action: :index}} = socket,
         %{"team_id" => team_id, "skill_panel_id" => skill_panel_id},
         _display_team,
         _display_skill_panel
       ) do
    # パラメータが完全に指定されていた場合、指定されたULIDの妥当性チェック
    try do
      Teams.raise_if_not_ulid(team_id)
      SkillPanelHelper.raise_if_not_ulid(skill_panel_id)
      socket
    rescue
      _e in Ecto.NoResultsError ->
        # パラメータ指定が不正な場合デフォルトでリダイレクト
        socket
        |> push_navigate(to: "/teams")
    end
  end

  defp assign_push_redirect(
         %{assigns: %{live_action: :index}} = socket,
         _params,
         %Team{} = display_team,
         %SkillPanel{} = display_skill_panel
       ) do
    # パラメータが完全に指定されていない場合、必要なデータが取得できていればパラメータを指定してリダイレクト
    socket
    |> push_navigate(to: "/teams/#{display_team.id}/skill_panels/#{display_skill_panel.id}")
  end

  defp assign_push_redirect(socket, _params, _display_team, _display_skill_panel) do
    # それ以外
    # パラメータが完全に指定されておらず、必要なデータも集められなかった場合
    # リダイレクトはしない
    socket
  end

  defp list_skill_classes(nil, _display_skill_panel) do
    # チームが取得できていない場合、スキルクラスとスコアを取得しない
    []
  end

  defp list_skill_classes(_display_team, nil) do
    # スキルパネルが取得できていない場合、スキルクラスとスコアを取得しない
    []
  end

  defp list_skill_classes(%Team{} = display_team, display_skill_panel) do
    # TODO 　チームメンバーのページング処理現状は上限が30名程度を想定して最大999件固定で取得
    %Scrivener.Page{
      page_number: _page_number,
      page_size: _page_size,
      total_entries: _total_entries,
      total_pages: _total_pages,
      entries: skill_classes
    } =
      Teams.list_skill_scores_by_team_id(
        display_team.id,
        display_skill_panel.id,
        %{page: 1, page_size: 999}
      )

    skill_classes
  end

  defp get_display_team_members(%Team{} = team) do
    %Scrivener.Page{
      page_number: _page_number,
      page_size: _page_size,
      total_entries: _total_entries,
      total_pages: _total_pages,
      entries: member_users
    } = Teams.list_joined_users_and_profiles_by_team_id(team.id, %{page: 1, page_size: 999})

    member_users
  end

  defp get_display_team_members(nil) do
    # チームが取得できていない場合、チームメンバーも取得しない
    []
  end

  defp get_current_users_team_member(current_user, display_team_members) do
    display_team_members
    |> Enum.find(fn team_member ->
      team_member.user_id == current_user.id
    end)
  end

  defp assign_current_users_team_member(socket, current_users_team_member) do
    socket
    |> assign(:current_users_team_member, current_users_team_member)
  end

  defp get_selected_skill_class(
         %{"skill_class_id" => skill_class_id},
         display_skill_classes
       ) do
    # URLパラメータにスキルクラスIDの指定がある場合該当のクラスを初期表示クラスとする
    selected_skill_class =
      display_skill_classes
      |> Enum.find(fn skill_class ->
        skill_class.id == skill_class_id
      end)

    if selected_skill_class == nil do
      # 該当のスキルクラスが取得できない場合は最初のクラスを採用
      get_selected_skill_class(%{}, display_skill_classes)
    else
      selected_skill_class
    end
  end

  defp get_selected_skill_class(_params, []) do
    nil
  end

  defp get_selected_skill_class(_params, display_skill_classes) do
    # URLパラメータにスキルクラスIDの指定がない場合は最初のスキルクラスを指定
    sorted_skill_classes =
      display_skill_classes
      |> Enum.sort(fn skill_class, n ->
        skill_class.class <= n.class
      end)

    List.first(sorted_skill_classes)
  end
end