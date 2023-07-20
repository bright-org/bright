# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.CommunicationCardComponent do
  @moduledoc """
  Communication Card Component
  """
  use BrightWeb, :live_component
  import BrightWeb.TabComponents
  alias Bright.Notifications

  @highlight_minutes 60 * 8
  @tabs ["スキルアップ", "1on1のお誘い", "所属チームから", "「気になる」された", "運勢公式チーム発足"]

  @doc """
  Renders a Communication Card

  ## Examples
      <.communication_card card={@card} />
  """

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h5>さまざまな人たちとの交流</h5>
      <.tab
        id="communication_card"
        tabs={@tabs}
        selected_tab={@card.selected_tab}
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

  def communication_card_row(assigns) do
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

  def create_card_param(selected_tab, page \\ 1) do
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

    card = %{card | notifications: notifications}

    socket
    |> assign(:card, card)
  end

  def communication_type("スキルアップ"), do: "skill_up"
  def communication_type("1on1のお誘い"), do: "1on1_invitation"
  def communication_type("所属チームから"), do: "from_your_team"
  def communication_type("「気になる」された"), do: "intriguing"
  def communication_type("運勢公式チーム発足"), do: "fortune_official_team_launched"
end
