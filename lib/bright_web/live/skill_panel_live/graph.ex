defmodule BrightWeb.SkillPanelLive.Graph do
  use BrightWeb, :live_view

  import BrightWeb.TimelineBarComponents
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
     |> assign_focus_user(params["user_name"])
     |> assign_skill_panel(params["skill_panel_id"])
     |> assign_skill_class_and_score(params["class"])
     |> create_skill_class_score_if_not_existing()
     |> assign_skill_units()
     |> assign_skill_score_dict()
     |> assign_counter()
     |> assign_page_sub_title()}
  end

  @impl true
  # TODO: デモ用実装のため対象ユーザー実装後に削除
  def handle_event("demo_change_user", _params, socket) do
    users =
      Bright.Accounts.User
      |> Bright.Repo.all()
      |> Enum.reject(fn user ->
        user.id == socket.assigns.current_user.id ||
          Ecto.assoc(user, :user_skill_panels)
          |> Bright.Repo.all()
          |> Enum.empty?()
      end)

    if users != [] do
      user = Enum.random(users)

      {:noreply,
       socket
       |> push_redirect(to: ~p"/panels/#{socket.assigns.skill_panel}/graph/#{user.name}")}
    else
      {:noreply,
       socket
       |> put_flash(:info, "demo: ユーザーがいません")
       |> push_redirect(to: ~p"/panels/#{socket.assigns.skill_panel}/graph")}
    end
  end

  # TODO: 検討：本実装で同じ処理をまるっと共通化するのはimportではできそうにない
  def handle_event("clear_focus_user", _params, socket) do
    {:noreply,
     socket
     |> push_redirect(to: ~p"/panels/#{socket.assigns.skill_panel}/graph")}
  end

  def handle_event(_event_name, _params, socket) do
    # # TODO タイムラインバーイベント検証 タイムラインイベント周りの実装後削除予定
    # IO.inspect("------------------")
    # IO.inspect(event_name)
    # IO.inspect(params)
    # IO.inspect("------------------")
    {:noreply, socket}
  end
end
