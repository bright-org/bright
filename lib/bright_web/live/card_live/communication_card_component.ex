# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.CommunicationCardComponent do
  @moduledoc """
  Communication Card Component
  """
  use BrightWeb, :live_component
  import BrightWeb.TabComponents
  alias Bright.Notifications

  @highlight_minutes 60 * 8
  @tabs ["スキルアップ", "1on1のお誘い", "推し活", "所属チーム", "気になる", "運勢公式"]

  @doc """
  Renders a Communication Card

  ## Examples
      <.communication_card card={@card} />
  """

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.tab
        id="communication_card"
        tabs={@tabs}
        selected_tab={@card.selected_tab}
        page={@card.page_params.page}
        total_pages={@card.total_pages}
        target={@myself}
      >
        <div class="pt-4 px-6">
          <ul class="flex gap-y-2.5 flex-col">
              <%= for notification <- @card.notifications do %>
                <.communication_card_row notification={notification} />
              <% end %>
          </ul>
        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:tabs, @tabs)
      |> assign(:card, create_card_param("スキルアップ"))
      |> assign_card()
    }
  end

  attr :notification, :map, required: true

  defp communication_card_row(assigns) do
    # TODO ↓contact_card_rowのソースと同じ　他のカードと考えて最終的には共通をすること
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

    # TODO ↑contact_card_rowのソースと同じ　他のカードと考えて最終的には共通をすること

    ~H"""
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 px-1">
      <span class="material-icons-outlined !text-sm !text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
        <%= @notification.icon_type %>
      </span>
      <%= @notification.message %>
      <span class={@style}><%= @time_text %></span>
    </li>
    """
  end

  # TODO ↓contact_card_rowのソースと同じ　他のカードと考えて最終的には共通をすること
  defp highlight(true), do: "text-brightGreen-300"
  defp highlight(false), do: "text-brightGray-300"

  # TODO ↑contact_card_rowのソースと同じ　他のカードと考えて最終的には共通をすること

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => "communication_card", "tab_name" => tab_name},
        socket
      ) do
    card = create_card_param(tab_name)

    socket
    |> assign(:card, card)
    |> assign_card()
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "previous_button_click",
        %{"id" => "communication_card"},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page - 1
    page = if page < 1, do: 1, else: page
    card_view(socket, card.selected_tab, page)
  end

  def handle_event(
        "next_button_click",
        %{"id" => "communication_card"},
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
    type = communication_type(card.selected_tab)

    notifications =
      Notifications.list_notification_by_type(
        user.id,
        type,
        card.page_params
      )

    card = %{card | notifications: notifications, total_pages: notifications.total_pages}

    socket
    |> assign(:card, card)
  end

  defp communication_type("スキルアップ"), do: "skill_up"
  defp communication_type("1on1のお誘い"), do: "1on1_invitation"
  defp communication_type("推し活"), do: "promotion"
  defp communication_type("所属チーム"), do: "your_team"
  defp communication_type("気になる"), do: "intriguing"
  defp communication_type("運勢公式"), do: "official_team"
end
