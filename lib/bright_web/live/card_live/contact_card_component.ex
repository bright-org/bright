# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.ContactCardComponent do
  @moduledoc """
  Contact Card Component
  """

  use BrightWeb, :live_component
  import BrightWeb.TabComponents
  import BrightWeb.CardLive.CardListComponents
  alias Bright.Notifications

  @tabs [
    {"team_invitation", "チーム招待"},
    {"daily", "デイリー"},
    {"weekly", "ウイークリー"},
    {"recruitment_coordination", "採用の調整"},
    {"skill_panel_update", "スキルパネル更新"},
    {"operation", "運営"}
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.tab
        id="contact_card"
        tabs={@tabs}
        selected_tab={@card.selected_tab}
        page={@card.page_params.page}
        total_pages={@card.total_pages}
        target={@myself}
      >
        <div class="pt-4 px-6 min-h-[216px]">

        <% # TODO α版対応 :if={@card.selected_tab == "operation"}を外すこと %>
          <ul :if={@card.selected_tab == "operation"} class="flex gap-y-2.5 flex-col">
            <li :if={Enum.count(@card.notifications) == 0} class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
                <%= Enum.into(@tabs, %{}) |> Map.get(@card.selected_tab) %>はありません
              </div>
            </li>
            <%= for notification <- @card.notifications do %>
              <.card_row type="operation" notification={notification} />
            <% end %>
          </ul>

          <% # TODO ↓α版対応 %>
          <ul :if={@card.selected_tab != "operation"} class="flex gap-y-2.5 flex-col">
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
                βリリース（10月予定）で利用可能になります
              </div>
            </li>
          </ul>
          <% # TODO ↑α版対応 %>

        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:tabs, @tabs)
     |> assign(:card, create_card_param("operation"))
     |> assign_card()}
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => "contact_card", "tab_name" => tab_name},
        socket
      ) do
    card_view(socket, tab_name, 1)
  end

  def handle_event(
        "previous_button_click",
        %{"id" => "contact_card"},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page - 1
    page = if page < 1, do: 1, else: page
    card_view(socket, card.selected_tab, page)
  end

  def handle_event(
        "next_button_click",
        %{"id" => "contact_card"},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page + 1

    page =
      if page > card.total_pages,
        do: card.total_pages,
        else: page

    card_view(socket, card.selected_tab, page)
  end

  defp card_view(socket, tab_name, page) do
    card = create_card_param(tab_name, page)

    socket
    |> assign(:card, card)
    |> assign_card()
    |> then(&{:noreply, &1})
  end

  defp create_card_param(selected_tab, page \\ 1) do
    %{
      selected_tab: selected_tab,
      notifications: [],
      page_params: %{page: page, page_size: 5},
      total_pages: 0
    }
  end

  # TODO α版が以降は　defp assign_card(%{assigns: %{current_user: user, card: card}} = socket) do　を採用
  defp assign_card(
         %{assigns: %{current_user: user, card: %{selected_tab: "operation"} = card}} = socket
       ) do
    # defp assign_card(%{assigns: %{current_user: user, card: card}} = socket) do
    notifications =
      Notifications.list_notification_by_type(
        user.id,
        card.selected_tab,
        card.page_params
      )

    card = %{
      card
      | notifications: notifications.entries,
        total_pages: notifications.total_pages
    }

    socket
    |> assign(:card, card)
  end

  # TODO α版対応
  defp assign_card(%{assigns: %{card: card}} = socket) do
    card = %{
      card
      | notifications: [],
        total_pages: 0
    }

    socket
    |> assign(:card, card)
  end
end
