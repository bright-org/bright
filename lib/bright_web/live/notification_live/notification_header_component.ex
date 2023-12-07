defmodule BrightWeb.NotificationLive.NotificationHeaderComponent do
  @moduledoc """
  Notification Header Components
  """
  use BrightWeb, :live_component
  alias Bright.Teams

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
      |> assign(:current_user, assigns.current_user)

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_notifications", _params, socket) do
    new_open? = !socket.assigns.open?

    socket
    |> assign(:open?, new_open?)
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
      ["学習メモのヘルプ", ~p"/notifications/evidences"]
    ]
  end
end
