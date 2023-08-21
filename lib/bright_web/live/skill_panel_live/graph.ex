defmodule BrightWeb.SkillPanelLive.Graph do
  use BrightWeb, :live_view

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
  def handle_params(params, url, socket) do
    # TODO: データ取得方法検討／LiveVIewコンポーネント化検討
    {:noreply,
     socket
     |> assign_path(url)
     |> assign_skill_classes()
     |> assign_skill_class_and_score(params["class"])
     |> create_skill_class_score_if_not_existing()
     |> assign_skill_score_dict()
     |> assign_counter()}
  end

  @impl true
  def handle_event("click_on_related_user_card_menu", params, socket) do
    # TODO: チームメンバー以外の対応時に匿名に注意すること
    user = Bright.Accounts.get_user_by_name(params["name"])

    # 参照可能なユーザーかどうかの判定は遷移先で行うので必要ない
    {:noreply,
     socket
     |> push_redirect(to: ~p"/graphs/#{socket.assigns.skill_panel}/#{user.name}")}
  end

  # TODO: 検討：本実装で同じ処理をまるっと共通化するのはimportではできそうにない
  def handle_event("clear_target_user", _params, socket) do
    {:noreply,
     socket
     |> push_redirect(to: ~p"/graphs/#{socket.assigns.skill_panel}")}
  end

  @impl true
  def handle_info(%{event_name: "timeline_bar_button_click", params: %{"date" => date}}, socket) do
    socket =
      socket
      |> assign(:select_label, date)

    {:noreply, socket}
  end
end
