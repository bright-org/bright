defmodule BrightWeb.SkillPanelLive.Graph do
  use BrightWeb, :live_view
  import BrightWeb.DoughnutGraphComponents
  import BrightWeb.GrowthGraphComponents
  alias Bright.SkillPanels

  # 全体が仮実装です。
  # - リソースロード回りは、Skillsと処理が被る可能性が高いです。参照（必要に応じて共通化）してください。

  @impl true
  def mount(_params, _session, socket) do
    # リンクを出すための実装
    # - 実際にはparamsからもろもろを引く
    skill_panel =
      SkillPanels.list_skill_panels()
      |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
      |> List.first()
      |> Bright.Repo.preload(:skill_classes)

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
end
