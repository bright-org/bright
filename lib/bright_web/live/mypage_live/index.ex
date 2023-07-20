defmodule BrightWeb.MypageLive.Index do
  use BrightWeb, :live_view
  import BrightWeb.ProfileComponents
  import BrightWeb.SkillScoreComponents
  import BrightWeb.SkillCardComponents
  import BrightWeb.IntriguingCardComponents
  import BrigntWeb.BrightModalComponents, only: [bright_modal: 1]
  alias Bright.Notifications

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "マイページ")
    # TODO 通知数はダミーデータ
    |> assign(:notification_count, "99")
    |> assign(:communication_card, create_card_param("スキルアップ"))
    |> assign_communication_card()
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => "communication_card", "tab_name" => tab_name} = _params,
        socket
      ) do
    communication_card = create_card_param(tab_name)

    socket
    |> assign(:communication_card, communication_card)
    |> assign_communication_card()
    |> then(&{:noreply, &1})
  end

  def handle_event(_event_name, _params, socket) do
    # TODO tabイベント検証 tabのイベント周りが完成後に削除予定
    # IO.inspect("------------------")
    # IO.inspect(_event_name)
    # IO.inspect(_params)
    # IO.inspect("------------------")
    {:noreply, socket}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "マイページ")
    |> assign(:mypage, nil)
  end

  def create_card_param(selected_tab, page \\ 1) do
    %{
      selected_tab: selected_tab,
      notifications: [],
      page_params: %{page: page, page_size: 5},
      total_pages: 0
    }
  end

  def assign_communication_card(socket) do
    type = communication_type(socket.assigns.communication_card.selected_tab)

    notifications =
      Notifications.list_notification_by_type(
        socket.assigns.current_user.id,
        type,
        socket.assigns.communication_card.page_params
      )

    communication_card = %{socket.assigns.communication_card | notifications: notifications}

    socket
    |> assign(:communication_card, communication_card)
  end

  def communication_type("スキルアップ"), do: "skill_up"
  def communication_type("1on1のお誘い"), do: "1on1_invitation"
  def communication_type("所属チームから"), do: "from_your_team"
  def communication_type("「気になる」された"), do: "intriguing"
  def communication_type("運勢公式チーム発足"), do: "fortune_official_team_launched"
end
