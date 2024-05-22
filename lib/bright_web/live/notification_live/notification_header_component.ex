defmodule BrightWeb.NotificationLive.NotificationHeaderComponent do
  @moduledoc """
  Notification Header Components
  """
  alias Bright.Notifications
  use BrightWeb, :live_component
  alias Bright.Teams
  alias Bright.Notifications
  alias Bright.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <button
        class="fixed top-3 right-28 mr-4 hover:opacity-70 lg:top-0 lg:ml-4 lg:right-0 lg:mr-0 lg:relative"
        phx-click="toggle_notifications"
        phx-click-away={@open? && "close_notifications"}
        phx-target={@myself}
      >
        <.icon name="hero-bell" class="h-8 w-8" />

        <span id="notification_unread_batch" :if={@has_new_notification?} class="absolute top-0 right-0 h-3 w-3 bg-attention-300 rounded-full" />

      </button>
      <div :if={@open?} class="absolute p-2 bg-brightGray-10 top-12 right-20 lg:right-24 shadow-lg">
        <ul>
          <%= for [title, link] <- @notification_list do %>
            <.link class="hover:opacity-70" href={link}>
              <li class="flex justify-between w-44 text-base my-2">
                <span><%= title %></span>
              </li>
            </.link>
          <% end %>
        </ul>
        <!-- 採用・育成支援への固定導線 -->
        <a
          :if={Teams.enable_hr_functions?(@current_user.id)}
          href="/team_supports"
          class="hover:opacity-70"
        >
          <li class="flex justify-between w-44 text-base my-2">
            <span>採用・育成支援</span>
          </li>
        </a>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket
    |> assign(:notification_list, notification_list())
    |> assign(:open?, false)
    |> then(&{:ok, &1})
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:current_user, assigns.current_user |> Repo.preload(:user_notification))
      |> assign_has_new_norification()

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_notifications", _params, socket) do
    new_open? = !socket.assigns.open?

    socket
    |> assign(:open?, new_open?)
    |> try_update_has_new_notification()
    |> then(&{:noreply, &1})
  end

  def handle_event("close_notifications", _params, socket) do
    socket
    |> assign(:open?, false)
    |> then(&{:noreply, &1})
  end

  defp notification_list do
    [
      ["コミュニティ", ~p"/notifications/communities"],
      ["運営", ~p"/notifications/operations"],
      ["学習メモのヘルプ", ~p"/notifications/evidences"],
      ["スキルアップ", ~p"/notifications/skill_updates"]
    ]
  end

  defp assign_has_new_norification(socket) do
    socket.assigns.current_user
    |> Notifications.has_unread_notification?()
    |> then(fn has_new_notification? ->
      socket
      |> assign(:has_new_notification?, has_new_notification?)
    end)
  end

  defp try_update_has_new_notification(
         %{assigns: %{has_new_notification?: true, current_user: user}} = socket
       ) do
    Notifications.view_notification(user)

    socket
    |> assign(:has_new_notification?, false)
  end

  defp try_update_has_new_notification(socket) do
    socket
  end
end
