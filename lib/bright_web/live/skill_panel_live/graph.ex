defmodule BrightWeb.SkillPanelLive.Graph do
  use BrightWeb, :live_view

  import BrightWeb.SkillPanelLive.SkillPanelComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "スキルパネル")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    # TODO: データ取得方法検討／LiveVIewコンポーネント化検討
    {:noreply,
     socket
     |> assign_skill_panel(params["skill_panel_id"])
     |> assign_skill_class_and_score(params["class"])
     |> create_skill_class_score_if_not_existing()
     |> assign_skill_units()
     |> assign_skill_score_dict()
     |> assign_counter()
     |> assign_page_sub_title()}
  end

  @impl true
  def handle_event(event_name, params, socket) do
    # TODO タイムラインバーイベント検証 タイムラインイベント周りの実装後削除予定
    IO.inspect("------グラフページ------------")
    IO.inspect(event_name)
    IO.inspect(params)
    IO.inspect("------------------")
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event_name: "timeline_bar_button_click", params: params}, socket) do
    IO.inspect("------グラフページ info------------")
    IO.inspect(params)
    IO.inspect("------------------")
    {:noreply, socket}
  end
end
