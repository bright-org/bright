defmodule BrightWeb.SkillPanelLive.Graph do
  use BrightWeb, :live_view
  import BrightWeb.ChartComponents
  import BrightWeb.TimelineBarComponents
  import BrightWeb.SkillPanelLive.SkillPanelComponents
  alias Bright.SkillPanels

  # 全体が仮実装です。
  # - リソースロード回りは、Skillsと処理が被る可能性が高いです。参照（必要に応じて共通化）してください。

  @impl true
  def mount(%{"skill_panel_id" => skill_panel_id}, _session, socket) do
    skill_panel = get_skill_panel(skill_panel_id)

    skill_class =
      skill_panel.skill_classes
      # 別タスクでクラスを表すカラムを追加必要（？）
      |> Enum.sort_by(& &1.inserted_at, {:asc, NaiveDateTime})
      |> List.first()

    {:ok,
     socket
     |> assign(:page_title, "スキルパネル")
     |> assign(:page_sub_title, skill_panel.name)
     |> assign(:skill_panel, skill_panel)
     |> assign(:skill_class, skill_class)}
  end


  defp get_skill_panel("dummy_id") do
    # TODO dummy_idはダミー用で実装完了後に消すこと
    # リンクを出すための実装
    # - 実際にはparamsからもろもろを引く

    SkillPanels.list_skill_panels()
    |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
    |> List.first()
    |> Bright.Repo.preload(:skill_classes)
  end

  defp get_skill_panel(skill_panel_id) do
    SkillPanels.get_skill_panel!(skill_panel_id)
    |> Bright.Repo.preload(:skill_classes)
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
