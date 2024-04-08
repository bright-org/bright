defmodule BrightWeb.MyTeamLive do
  @moduledoc """
  チームスキル分析画面
  """
  use BrightWeb, :live_view
  import BrightWeb.TeamComponents
  import BrightWeb.MegaMenuComponents
  import BrightWeb.BrightModalComponents

  alias Bright.Teams
  alias Bright.Teams.Team
  alias Bright.CustomGroups
  alias BrightWeb.TeamLive.MyTeamHelper

  def mount(params, _session, socket) do
    # スキルとチームの取得結果に応じて各種assign
    {:ok, MyTeamHelper.init_assign(params, socket)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"team_id" => id}) do
    team = Teams.get_team_with_member!(id)

    socket
    |> assign(:action, :edit)
    |> assign(:team, team)
    |> assign(:users, Enum.filter(team.users, &(&1.id != socket.assigns.current_user.id)))
  end

  defp apply_action(socket, _action, _params) do
    socket
    |> assign(:team, %Team{})
    |> assign(:users, [])
  end

  def handle_event("click_star_button", _params, socket) do
    {:ok, team_member_user} = Teams.toggle_is_star(socket.assigns.current_users_team_member)

    socket =
      socket
      |> assign(:current_users_team_member, team_member_user)

    {:noreply, socket}
  end

  def handle_event("on_card_row_click", %{"team_type" => "custom_group"} = params, socket) do
    # メガメニューのチームカードからカスタムグループの行をクリックした場合のハンドラー
    # display_teamを選択したカスタムグループで更新し、リダイレクトする。
    # その際、選択済のスキルパネル、またはスキルセットがある場合IDを引き継ぐ
    # スキルクラスは引き継がず初期化する
    %{current_user: current_user, display_skill_panel: skill_panel} = socket.assigns

    display_team =
      CustomGroups.get_custom_group_by!(id: params["team_id"], user_id: current_user.id)

    display_skill_panel_id = (skill_panel || %{id: nil}).id

    socket =
      socket
      |> assign(:display_team, display_team)
      |> deside_redirect(display_team, display_skill_panel_id, nil)

    {:noreply, socket}
  end

  def handle_event("on_card_row_click", params, socket) do
    # メガメニューのチームカードからチームの行をクリックした場合のハンドラー
    # display_teamを選択したチームのチームIDで更新し、リダイレクトする。
    # その際、選択済のスキルパネル、またはスキルセットがある場合IDを引き継ぐ
    # スキルクラスは引き継がず初期化する

    display_team = Teams.get_team_with_member_users!(params["team_id"])

    display_skill_panel_id =
      if is_nil(socket.assigns.display_skill_panel) do
        nil
      else
        socket.assigns.display_skill_panel.id
      end

    socket =
      socket
      |> assign(:display_team, display_team)
      |> deside_redirect(display_team, display_skill_panel_id, nil)

    {:noreply, socket}
  end

  def handle_event("on_skill_pannel_click", %{"skill_panel_id" => skill_panel_id}, socket) do
    # メガメニューのスキルパネルカードからスキルクラスをクリックした場合のハンドラー
    # 指定されているチームを引き継いで該当のスキルパネルを指定してリダイレクトする
    socket =
      socket
      |> deside_redirect(socket.assigns.display_team, skill_panel_id, nil)

    {:noreply, socket}
  end

  def handle_event(
        "on_skill_class_click",
        %{"skill_panel_id" => skill_panel_id, "skill_class_id" => skill_class_id},
        socket
      ) do
    # メガメニューのスキルパネルカードからスキルクラスをクリックした場合のハンドラー
    # 指定されているチーム、スキルパネルを引き継いで該当のスキルクラスをURLパラメータに指定してリダイレクトする
    socket =
      socket
      |> deside_redirect(socket.assigns.display_team, skill_panel_id, skill_class_id)

    {:noreply, socket}
  end

  def handle_event("cancel_team_create", _params, socket) do
    # チーム作成モーダルキャンセル時の挙動
    # /teamsへリダイレクト
    case socket.assigns.display_team do
      nil ->
        {:noreply, redirect(socket, to: "/teams")}

      team ->
        {:noreply, deside_redirect(socket, team, nil, nil)}
    end
  end

  def handle_event("toggle_show_hr_support_modal", _params, socket) do
    {:noreply, assign(socket, :show_hr_support_modal, !socket.assigns.show_hr_support_modal)}
  end

  def handle_info({BrightWeb.TeamLive.TeamAddUserComponent, {:add, added_users}}, socket) do
    {:noreply, assign(socket, :users, added_users)}
  end

  def handle_info({:plan_changed, plan}, socket) do
    {:noreply, assign(socket, :plan, plan)}
  end

  defp deside_redirect(socket, display_team, skill_panel_id, skill_class_id) do
    socket
    |> redirect(to: MyTeamHelper.get_my_team_path(display_team, skill_panel_id, skill_class_id))
  end
end
