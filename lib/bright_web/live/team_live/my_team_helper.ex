defmodule BrightWeb.TeamLive.MyTeamHelper do
  @moduledoc """
  チームの表示に関するモジュール
  """
  import Phoenix.Component, only: [assign: 3]
  import Phoenix.LiveView, only: [push_navigate: 2]

  alias Bright.Accounts
  alias Bright.Teams
  alias Bright.Teams.Team
  alias Bright.CustomGroups
  alias Bright.CustomGroups.CustomGroup
  alias Bright.SkillPanels
  alias Bright.SkillScores
  alias Bright.Subscriptions
  alias Bright.SkillPanels.SkillPanel
  alias Bright.SkillPanels.SkillClass

  def init_assign(params, %{assigns: %{live_action: :new, current_user: user}} = socket) do
    subscription = Subscriptions.get_user_subscription_user_plan(user.id)

    # 直接チーム作成モーダルを起動した場合、データの取得は行わない
    socket
    |> assign(:show_hr_support_modal, false)
    |> assign(:hr_enabled, Accounts.hr_enabled?(user.id))
    |> assign_plan(subscription)
    |> assign_page_title()
    |> assign_display_type(params["type"])
    |> assign_display_skill_panel(nil)
    |> assign_display_skill_classes([])
    |> assign_display_skill_class(nil)
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

  def init_assign(params, %{assigns: %{current_user: user}} = socket) do
    # パラメータ指定がある場合それぞれの対象データを取得、ない場合はnil
    display_team = get_display_team(params, user.id)
    # TODO チームスキルカードのページング処理
    display_team_members = get_display_team_members(display_team, user)

    current_users_team_member = get_current_users_team_member(user, display_team_members)

    display_skill_panel = get_display_skill_panel(params, display_team_members)
    display_skill_classes = list_display_skill_classes(display_skill_panel)
    selected_skill_class = get_selected_skill_class(params, display_skill_classes)
    member_skill_class_scores = list_skill_class_scores(display_team_members, display_skill_panel)
    subscription = Subscriptions.get_user_subscription_user_plan(user.id)

    level = [:beginner, :normal, :skilled]

    level_count =
      Enum.map(level, fn l ->
        Enum.map(1..3, fn c -> level_count(member_skill_class_scores, c, l) end)
      end)

    # スキルとチームの取得結果に応じて各種assign
    socket
    |> assign(:show_hr_support_modal, false)
    |> assign(:hr_enabled, Accounts.hr_enabled?(user.id))
    |> assign_plan(subscription)
    |> assign_page_title()
    |> assign_display_type(params["type"])
    |> assign_display_skill_panel(display_skill_panel)
    |> assign_display_skill_classes(display_skill_classes)
    |> assign_display_skill_class(selected_skill_class)
    |> assign_display_team(display_team)
    |> assign_current_users_team_member(current_users_team_member)
    # ユーザー事に表示するスキルカードのmap作成とassign
    |> assign_display_skill_cards(
      display_team_members,
      display_skill_classes,
      selected_skill_class,
      member_skill_class_scores
    )
    # パラメータの指定内容とデータの取得結果によってリダイレクトを指定
    |> assign_push_redirect(params, display_team, display_skill_panel)
    |> assign(:team_size, length(display_team_members))
    |> assign(:level_count, level_count)
  end

  defp level_count(member_skill_class_scores, class, level) do
    member_skill_class_scores
    |> Enum.count(fn x -> x.skill_class.class == class and x.level == level end)
  end

  defp get_display_skill_panel(%{"skill_panel_id" => skill_panel_id}, _display_team_members) do
    # TODO チームの誰も保有していないスキルパネルが指定された場合エラーにする必要はないはず
    try do
      SkillPanels.get_skill_panel!(skill_panel_id)
    rescue
      # 結果が取得できない場合握りつぶしてnilを返す
      Ecto.NoResultsError -> nil
      Ecto.Query.CastError -> nil
    end
  end

  defp get_display_skill_panel(_params, []) do
    # TODO スキルパネルIDが指定されていない場合、チームも取得できない場合はnil
    nil
  end

  defp get_display_skill_panel(_params, display_team_members) do
    # TODO スキルパネルIDが指定されていない場合、チームが取得できていれば第一優先のスキルパネルを取得する
    user_ids = Enum.map(display_team_members, & &1.user_id)

    # キャリアフィールドを問わずチーム内の設定スキルのうち最も新しいスキルパネルを取得
    %{page_number: _page, total_pages: _total_pages, entries: skill_panels} =
      SkillPanels.list_users_skill_panels(user_ids, 1)

    List.first(skill_panels)
  end

  defp list_display_skill_classes(%SkillPanel{} = skill_panel) do
    SkillPanels.get_all_skill_classes_by_skill_panel_id(skill_panel.id)
  end

  defp list_display_skill_classes(_skill_panel) do
    # スキルパネルが取得できていない場合、スキルクラスを取得しない
    []
  end

  defp iam_team_member?(team, user_id) do
    team.member_users
    |> Enum.any?(fn member_user ->
      member_user.user_id == user_id && !is_nil(member_user.invitation_confirmed_at)
    end)
  end

  defp get_display_team(%{"team_id" => team_id}, user_id) do
    try do
      team = Teams.get_team_with_member_users!(team_id)

      # 対象チームのチームメンバーの場合、または支援関係のあるチームメンバーの場合のみ参照可能
      if iam_team_member?(team, user_id) ||
           Teams.is_my_supportee_team_or_supporter_team?(user_id, team.id) do
        team
      else
        # 所属関係による権限がない場合ユーザーには404表示
        raise(Bright.Exceptions.ForbiddenResourceError)
      end
    rescue
      # 結果が取得できない場合、カスタムグループ判定に移動
      Ecto.NoResultsError -> get_display_team_as_custom_group(team_id, user_id)
      Ecto.Query.CastError -> get_display_team_as_custom_group(team_id, user_id)
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

  defp get_display_team_as_custom_group(custom_group_id, user_id) do
    try do
      CustomGroups.get_custom_group_by!(id: custom_group_id, user_id: user_id)
    rescue
      _e in Ecto.NoResultsError ->
        # 結果が取得できない場合握りつぶしてnilを返す
        nil
    end
  end

  defp assign_plan(socket, nil), do: assign(socket, :plan, nil)

  defp assign_plan(socket, subscription) do
    assign(socket, :plan, subscription.subscription_plan)
  end

  defp assign_page_title(socket) do
    socket
    |> assign(:page_title, "チームスキル分析")
  end

  defp assign_display_type(socket, "custom_group") do
    assign(socket, :display_type, "custom_group")
  end

  defp assign_display_type(socket, _type) do
    assign(socket, :display_type, "team")
  end

  defp assign_display_team(socket, display_team) do
    socket
    |> assign(:display_team, display_team)
  end

  defp assign_display_skill_class(socket, display_skill_class) do
    socket
    |> assign(:display_skill_class, display_skill_class)
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
         member_skill_class_scores
       ) do
    display_member_for_skill_card =
      team_member_users
      |> Enum.map(fn member ->
        # ユーザー毎に該当ユーザーのスキルクラススコアが取得出来ているか検索
        filterd_member_skill_class_scores =
          member_skill_class_scores
          |> Enum.filter(fn member_skill_class ->
            member_skill_class.user_id == member.user.id
          end)

        %{user: member.user}
        |> add_user_skill_class_score(display_skill_classes, filterd_member_skill_class_scores)
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

  defp add_user_skill_class_score(map, display_skill_classes, filterd_member_skill_class_scores) do
    # display_skill_classesに対応する該当ユーザーのスキルクラススコアが存在するかチェック
    # 存在しない場合はnilを設定する
    user_skill_class_score =
      display_skill_classes
      |> Enum.map(fn display_skill_class ->
        skill_class_score =
          filterd_member_skill_class_scores
          |> Enum.find(fn filterd_member_skill_class_score ->
            filterd_member_skill_class_score.skill_class_id == display_skill_class.id
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
         %{"team_id" => _team_id, "skill_panel_id" => _skill_panel_id},
         _display_team,
         _display_skill_panel
       ) do
    # パラメータが完全に指定されていた場合、処理を続行
    socket
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

  defp list_skill_class_scores([], _display_skill_panel) do
    # チームメンバーが取得できていない場合、スキルクラスとスコアを取得しない
    []
  end

  defp list_skill_class_scores(_display_team_members, nil) do
    # スキルパネルが取得できていない場合、スキルクラスとスコアを取得しない
    []
  end

  defp list_skill_class_scores(display_team_members, display_skill_panel) do
    # TODO 　チームメンバーのページング処理現状は上限が30名程度を想定して最大999件固定で取得
    user_ids = Enum.map(display_team_members, & &1.user_id)

    %Scrivener.Page{
      page_number: _page_number,
      page_size: _page_size,
      total_entries: _total_entries,
      total_pages: _total_pages,
      entries: skill_classes
    } =
      SkillScores.list_users_skill_class_scores_by_skill_panel_id(
        user_ids,
        display_skill_panel.id,
        %{page: 1, page_size: 999}
      )

    skill_classes
  end

  defp get_display_team_members(%Team{} = team, _user) do
    %Scrivener.Page{
      page_number: _page_number,
      page_size: _page_size,
      total_entries: _total_entries,
      total_pages: _total_pages,
      entries: member_users
    } = Teams.list_joined_users_and_profiles_by_team_id(team.id, %{page: 1, page_size: 999})

    member_users
  end

  defp get_display_team_members(%CustomGroup{} = custom_group, user) do
    custom_group = Bright.Repo.preload(custom_group, member_users: [user: [:user_profile]])

    # 前処理として参照時点で無効になっているメンバー除去
    {_, invalid_users} = CustomGroups.filter_valid_users(custom_group)
    invalid_user_ids = Enum.map(invalid_users, & &1.id)

    # メンバーと自分自身を一覧に加える
    custom_group.member_users
    |> Enum.reject(&(&1.user_id in invalid_user_ids))
    |> then(&([%{user_id: user.id, user: user}] ++ &1))
  end

  defp get_display_team_members(nil, _user) do
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

  def get_my_team_path(nil, nil, nil) do
    "/teams"
  end

  def get_my_team_path(display_team, %SkillPanel{} = skill_panel, %SkillClass{} = skill_class) do
    get_my_team_path(display_team, skill_panel.id, skill_class.id)
  end

  def get_my_team_path(display_team, %SkillPanel{} = skill_panel, nil) do
    get_my_team_path(display_team, skill_panel.id, nil)
  end

  def get_my_team_path(display_team, nil, nil) do
    "/teams/#{display_team.id}"
  end

  def get_my_team_path(display_team, skill_panel_id, nil) do
    "/teams/#{display_team.id}/skill_panels/#{skill_panel_id}"
  end

  def get_my_team_path(display_team, skill_panel_id, skill_class_id) do
    "/teams/#{display_team.id}/skill_panels/#{skill_panel_id}?skill_class_id=#{skill_class_id}"
  end
end
