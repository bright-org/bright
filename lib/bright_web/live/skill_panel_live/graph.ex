defmodule BrightWeb.SkillPanelLive.Graph do
  use BrightWeb, :live_view
  use BrightWeb.SkillPanelLive.SkillPanel

  import BrightWeb.ChartComponents
  import BrightWeb.TimelineBarComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "スキルパネル")}
  end

  @impl true
  def handle_params(params, url, socket) do
    {:noreply,
     socket
     |> assign_path(url)
     |> assign_skill_panel(params["skill_panel_id"])
     |> assign_page_sub_title()
     |> assign_skill_class_and_score(params["class"])}
  end

  @impl true
  def handle_event(_event_name, _params, socket) do
    # # TODO タイムラインバーイベント検証 タイムラインイベント周りの実装後削除予定
    # IO.inspect("------------------")
    # IO.inspect(event_name)
    # IO.inspect(params)
    # IO.inspect("------------------")
    {:noreply, socket}
  end
end
