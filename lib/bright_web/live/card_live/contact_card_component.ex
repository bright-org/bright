# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.ContactCardComponent do
  @moduledoc """
  Contact Card Component
  """

  use BrightWeb, :live_component
  import BrightWeb.TabComponents
  import BrightWeb.CardLive.CardListComponents
  alias Bright.Notifications

  @tabs ["チーム招待", "デイリー", "ウイークリー", "採用の調整", "スキルパネル更新", "運営"]

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
        <div class="pt-4 pb-1 px-8">
          <ul class="flex gap-y-2.5 flex-col">
            <%= for notification <- @card.notifications do %>
              <.contact_card_row notification={notification} />
            <% end %>
          </ul>
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
     |> assign(:card, create_card_param("チーム招待"))
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

  defp assign_card(%{assigns: %{current_user: user, card: card}} = socket) do
    type = contact_type(card.selected_tab)

    notifications =
      Notifications.list_notification_by_type(
        user.id,
        type,
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

  defp contact_type("チーム招待"), do: "team invite"
  defp contact_type("デイリー"), do: "daily"
  defp contact_type("ウイークリー"), do: "weekly"
  defp contact_type("採用の調整"), do: "recruitment_coordination"
  defp contact_type("スキルパネル更新"), do: "skill_panel_update"
  defp contact_type("運営"), do: "operation"
end
