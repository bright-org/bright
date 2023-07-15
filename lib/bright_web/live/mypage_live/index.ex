defmodule BrightWeb.MypageLive.Index do
  alias Bright.UserProfiles
  use BrightWeb, :live_view
  import BrightWeb.ProfileComponents
  import BrightWeb.SkillScoreComponents
  import BrightWeb.ContactCardComponents
  import BrightWeb.SkillCardComponents
  import BrightWeb.CommunicationCardComponents
  import BrightWeb.IntriguingCardComponents
  alias Bright.UserProfiles
  alias Bright.Notifications

  @impl true
  def mount(_params, _session, socket) do
    profile = UserProfiles.get_user_profile_by_name(socket.assigns.current_user.name)

    socket
    |> assign(:page_title, "マイページ")
     # TODO 通知数はダミーデータ
    |> assign(:notification_count, "99")
    |> assign(:profile, profile)
    |> assign(:contact_card, create_card_param("チーム招待"))
    |> assign_contact_card()
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true

  def handle_event(
        "tab_click",
        %{"id" => "contact_card", "tab_name" => tab_name} = _params,
        socket
      ) do
    contact_card = create_card_param(tab_name)

    socket
    |> assign(:contact_card, contact_card)
    |> assign_contact_card()
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

  def create_card_param(selected_tab) do
    %{selected_tab: selected_tab, notifications: []}
  end

  def assign_contact_card(socket) do
    type = contact_type(socket.assigns.contact_card.selected_tab)

    notifications =
      Notifications.list_notification_by_type(
        socket.assigns.current_user.id,
        type
      )

    contact_card = %{socket.assigns.contact_card | notifications: notifications}

    socket
    |> assign(:contact_card, contact_card)
  end

  def contact_type("チーム招待"), do: "team invite"
  def contact_type("デイリー"), do: "daily"
  def contact_type("ウイークリー"), do: "weekly"
  def contact_type("採用の調整"), do: "recruitment_coordination"
  def contact_type("スキルパネル更新"), do: "skill_panel_update"
  def contact_type("運営"), do: "operation"
end
