defmodule BrightWeb.SkillPanelLive.Graph do
  use BrightWeb, :live_view

  import BrightWeb.TimelineBarComponents
  import BrightWeb.SkillPanelLive.SkillPanelComponents

  alias Bright.SkillPanels

  # 全体が仮実装です。
  # - リソースロード回りは、Skillsと処理が被る可能性が高いです。参照（必要に応じて共通化）してください。

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "スキルパネル")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign_skill_panel(params["skill_panel_id"])
     |> assign_page_sub_title()
     |> assign_skill_class_and_score(params["class"])}
  end

  defp assign_skill_panel(socket, "dummy_id") do
    # TODO: dummy_idはダミー用で実装完了後に消すこと
    # リンクを出すための実装
    skill_panel =
      SkillPanels.list_skill_panels()
      |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
      |> List.first()

    assign_skill_panel(socket, skill_panel.id)
  end

  defp assign_skill_panel(socket, skill_panel_id) do
    current_user = socket.assigns.current_user

    skill_panel =
      SkillPanels.get_skill_panel!(skill_panel_id)
      |> Bright.Repo.preload(
        skill_classes: [skill_class_scores: Ecto.assoc(current_user, :skill_class_scores)]
      )

    socket
    |> assign(:skill_panel, skill_panel)
  end

  defp assign_skill_class_and_score(socket, nil), do: assign_skill_class_and_score(socket, "1")

  defp assign_skill_class_and_score(socket, class) do
    class = String.to_integer(class)
    skill_class = socket.assigns.skill_panel.skill_classes |> Enum.find(&(&1.class == class))
    # List.first(): preload時に絞り込んでいるためfirstで取得可能
    skill_class_score = skill_class.skill_class_scores |> List.first()

    socket
    |> assign(:skill_class, skill_class)
    |> assign(:skill_class_score, skill_class_score)
  end

  defp assign_page_sub_title(socket) do
    socket
    |> assign(:page_sub_title, socket.assigns.skill_panel.name)
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
