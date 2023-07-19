# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.ContactCardComponent do
  @moduledoc """
  Contact Card Component
  """

  use BrightWeb, :live_component
  import BrightWeb.TabComponents
  alias Bright.Notifications

  @highlight_minutes 60 * 8

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h5>重量な連絡</h5>
      <.tab id="contact_card" tabs={["チーム招待", "デイリー", "ウイークリー", "採用の調整", "スキルパネル更新", "運営"]} selected_tab={@card.selected_tab} page={@card.page_params.page} total_pages={@card.total_pages}  target={@myself}>
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
     |> assign(:card, create_card_param("チーム招待"))
     |> assign_contact_card()}
  end

  def contact_card_row(assigns) do
    {:ok, inserted_at} = DateTime.from_naive(assigns.notification.inserted_at, "Etc/UTC")

    minutes =
      DateTime.diff(DateTime.utc_now(), inserted_at, :minute)
      |> trunc()

    time_text = if minutes < 60, do: "#{minutes}分前", else: "#{trunc(minutes / 60)}時間前"

    style = highlight(minutes < @highlight_minutes) <> " font-bold pl-4 inline-block"

    assigns =
      assigns
      |> assign(:style, style)
      |> assign(:time_text, time_text)

    ~H"""
    <li class="text-left flex items-center text-base">
      <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
        <%= @notification.icon_type %>
      </span>
      <%= @notification.message %>
      <span class={@style}><%= @time_text %></span>
    </li>
    """
  end

  defp highlight(true), do: "text-brightGreen-300"
  defp highlight(false), do: "text-brightGray-300"

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => "contact_card", "tab_name" => tab_name} = _params,
        socket
      ) do
    contact_card_view(socket, tab_name, 1)
  end

  def handle_event(
        "previous_button_click",
        %{"id" => "contact_card"} = _params,
        socket
      ) do
    contact_card = socket.assigns.card
    page = contact_card.page_params.page - 1
    page = if page < 1, do: 1, else: page
    contact_card_view(socket, contact_card.selected_tab, page)
  end

  def handle_event(
        "next_button_click",
        %{"id" => "contact_card"} = _params,
        socket
      ) do
    contact_card = socket.assigns.card
    page = contact_card.page_params.page + 1

    page =
      if page > contact_card.total_pages,
        do: contact_card.total_pages,
        else: page

    contact_card_view(socket, contact_card.selected_tab, page)
  end

  def create_card_param(selected_tab, page \\ 1) do
    %{
      selected_tab: selected_tab,
      notifications: [],
      page_params: %{page: page, page_size: 5},
      total_pages: 0
    }
  end

  def contact_card_view(socket, tab_name, page \\ 1) do
    contact_card = create_card_param(tab_name, page)

    socket
    |> assign(:card, contact_card)
    |> assign_contact_card()
    |> then(&{:noreply, &1})
  end

  def assign_contact_card(socket) do
    type = contact_type(socket.assigns.card.selected_tab)

    notifications =
      Notifications.list_notification_by_type(
        socket.assigns.current_user.id,
        type,
        socket.assigns.card.page_params
      )

    card = %{
      socket.assigns.card
      | notifications: notifications.entries,
        total_pages: notifications.total_pages
    }

    socket
    |> assign(:card, card)
  end

  def contact_type("チーム招待"), do: "team invite"
  def contact_type("デイリー"), do: "daily"
  def contact_type("ウイークリー"), do: "weekly"
  def contact_type("採用の調整"), do: "recruitment_coordination"
  def contact_type("スキルパネル更新"), do: "skill_panel_update"
  def contact_type("運営"), do: "operation"
end
