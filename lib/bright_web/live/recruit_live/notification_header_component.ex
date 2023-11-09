defmodule BrightWeb.RecruitLive.NotificationHeaderComponent do
  @moduledoc """
  Notification Header Components for Recruit
  """
  use BrightWeb, :live_component

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
        <ul>
          <%= for [title, link] <- @notification_list do %>
            <.link class="hover:opacity-70" href={link}>
              <li class="flex justify-between w-44 text-base my-2">
                <span><%= title %></span>
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

  defp notification_list do
    [
      ["面談調整", ~p"/recuits/interview"]
    ]
  end
end
