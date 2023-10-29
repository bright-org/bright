defmodule BrightWeb.NotificationLive.NotificationHeaderComponent do
  @moduledoc """
  Notification Header Components
  """
  use BrightWeb, :live_component
  alias Bright.Notifications

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <button
        class="fixed top-3 right-16 mr-4 hover:opacity-70 lg:top-0 lg:ml-4 lg:right-0 lg:mr-0 lg:relative"
        phx-click="toggle_notifications"
        phx-target={@myself}
      >
        <.icon name="hero-bell" class="h-8 w-8" />
      </button>
      <div :if={@open?} class="absolute p-2 bg-brightGray-10 top-12 right-20 lg:right-24 shadow-lg">
        <p class="text-xs">【下記は11月中旬リリース予定】</p>
        <ul>
          <%= for [title, link, notification_count] <- @notification_list do %>
            <.link class="hover:opacity-70" href={link}>
              <li class="flex justify-between w-44 text-base my-2">
                <span><%= title %></span>
                <span :if={notification_count != 0} class="bg-brightGreen-300 text-white inline-flex items-center justify-center w-6 h-6 ml-2 text-xs font-semibold rounded-full">
                  <%= if notification_count > 99, do: "99+", else: notification_count %>
                </span>
              </li>
            </.link>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket
    |> assign(:notification_list, [])
    |> assign(:open?, false)
    |> then(&{:ok, &1})
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:current_user, assigns.current_user)

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_notifications", _params, socket) do
    new_open? = !socket.assigns.open?

    socket
    |> assign(:open?, new_open?)
    |> assign(:notification_list, notification_list(socket.assigns, new_open?))
    |> then(&{:noreply, &1})
  end

  # NOTE: 無駄なクエリを減らすため通知ヘッダーを開く時のみ未読数を取得
  defp notification_list(%{current_user: current_user} = _assigns, true) do
    notification_count = Notifications.list_unconfirmed_notification_count(current_user)

    [
      ["コミュニティ", "#", 0],
      ["1on1のお誘い", "#", 0],
      ["推し活", "#", 0],
      ["いただいた祝福", "#", 0],
      ["スキルアップ", "#", 0],
      ["振り返り", "#", 0],
      ["運営", ~p"/notifications/operations", notification_count["operation"] || 0]
    ]
  end

  defp notification_list(%{notification_list: notification_list} = _assigns, false) do
    notification_list
  end
end
