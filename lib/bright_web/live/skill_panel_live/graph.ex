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
     |> assign_counter()}
  end

  def handle_params(_params, _url, %{assigns: %{skill_panel: nil}} = socket),
    do: {:noreply, socket}

  @impl true
  # TODO: デモ用実装のため対象ユーザー実装後に削除
  # TODO: 匿名に注意すること
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
       |> push_redirect(to: ~p"/graphs/#{socket.assigns.skill_panel}/#{user.name}")}
    else
      {:noreply,
       socket
       |> put_flash(:info, "demo: ユーザーがいません")
       |> push_redirect(to: ~p"/graphs/#{socket.assigns.skill_panel}")}
    end
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
