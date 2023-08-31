defmodule BrightWeb.SkillPanelLive.Graph do
  use BrightWeb, :live_view

  alias Bright.SkillPanels.SkillPanel

  import BrightWeb.SkillPanelLive.SkillPanelComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper
  import BrightWeb.DisplayUserHelper

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign_display_user(params)
     |> assign_skill_panel(params["skill_panel_id"], "graphs")
     |> assign(:select_label, "now")
     |> assign(:page_title, "スキルパネル")
     |> assign_page_sub_title()}
  end

  @impl true
  def handle_params(params, url, %{assigns: %{skill_panel: %SkillPanel{}}} = socket) do
    # TODO: データ取得方法検討／LiveVIewコンポーネント化検討
    {:noreply,
     socket
     |> assign_path(url)
     |> assign_skill_classes()
     |> assign_skill_class_and_score(params["class"])
     |> create_skill_class_score_if_not_existing()
     |> assign_skill_score_dict()
     |> assign_counter()
     |> touch_user_skill_panel()}
  end

  def handle_params(_params, _url, %{assigns: %{skill_panel: nil}} = socket),
    do: {:noreply, socket}

  @impl true
  def handle_event(
        "click_on_related_user_card_menu",
        %{"encrypt_user_name" => encrypt_user_name},
        socket
      )
      when encrypt_user_name != "" do
    {:noreply,
     push_redirect(socket, to: ~p"/graphs/#{socket.assigns.skill_panel}/anon/#{encrypt_user_name}")}
  end

  @impl true
  def handle_event("click_on_related_user_card_menu", params, socket) do
    # TODO: チームメンバー以外の対応時に匿名に注意すること
    user = Bright.Accounts.get_user_by_name(params["name"])

    # 参照可能なユーザーかどうかの判定は遷移先で行うので必要ない
    {:noreply, push_redirect(socket, to: ~p"/graphs/#{socket.assigns.skill_panel}/#{user.name}")}
  end

  def handle_event("clear_display_user", _params, socket) do
    %{current_user: current_user, skill_panel: skill_panel} = socket.assigns
    move_to = get_path_to_switch_me("graphs", current_user, skill_panel)

    {:noreply, push_redirect(socket, to: move_to)}
  end

  @impl true
  def handle_info(%{event_name: "timeline_bar_button_click", params: %{"date" => date}}, socket) do
    socket =
      socket
      |> assign(:select_label, date)

    {:noreply, socket}
  end
end
