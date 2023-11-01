defmodule BrightWeb.NotificationLive.Community do
  use BrightWeb, :live_view
  alias Bright.Notifications
  alias BrightWeb.CardLive.CardListComponents
  alias BrightWeb.TabComponents
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @default_page 1
  @page_per 10

  @impl true
  def render(assigns) do
    ~H"""
    <div id="notification_community_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">
        <li :if={Enum.count(@notifications) == 0} class="flex">
          <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
          コミュニティからの通知はありません
          </div>
        </li>
        <%= for notification <- @notifications do %>
          <li class="flex flex-wrap my-5">
            <div phx-click="confirm_notification" phx-value-notification_community_id={notification.id} class="cursor-pointer hover:opacity-70 text-left flex flex-wrap items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate">
              <span class="material-icons text-lg text-white bg-brightGreen-300 rounded-full flex w-6 h-6 mr-2.5 items-center justify-center">
                person
              </span>
              <span class={"order-3 lg:order-2 flex-1 mr-2 truncate"}><%= notification.message %></span>
              <CardListComponents.elapsed_time inserted_at={notification.inserted_at} />
            </div>
            <div class="flex gap-x-2 w-full justify-end lg:justify-start lg:w-auto">
              <button phx-click="confirm_notification" phx-value-notification_community_id={notification.id} class="hidden hover:opacity-70 font-bold lg:inline-block bg-brightGray-900 text-white min-w-[76px] rounded p-2 text-sm">
                内容を見る
              </button>
            </div>
          </li>
        <% end %>
        <TabComponents.tab_footer id="notification_community_footer" page={@page} total_pages={@total_pages} target={"#notification_community_container"} />
      </div>
    </div>

    <.bright_modal
      :if={@shown_notification_community != nil}
      id="notification_community_modal"
      style_of_modal_flame_out="w-full max-w-3xl p-4 sm:p-6 lg:py-8"
      show
      on_cancel={JS.push("close_modal")}>

      <.header class="break-words"><%= @shown_notification_community.message %></.header>

      <div class="mt-4">
        <%= Phoenix.HTML.Format.text_to_html(@shown_notification_community.detail, attributes: [class: "break-all"]) %>
      </div>
    </.bright_modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    %{entries: notifications, total_pages: total_pages} =
      get_notifications(
        socket.assigns.current_user.id,
        @default_page,
        @page_per
      )

    socket
    |> assign(:page_title, "コミュニティからの通知")
    |> assign(:page, @default_page)
    |> assign(:total_pages, total_pages)
    |> assign(:notifications, notifications)
    |> assign(:shown_notification_community, nil)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("previous_button_click", _params, socket) do
    new_page = socket.assigns.page - 1

    %{entries: new_notifications, total_pages: new_total_pages} =
      get_notifications(
        socket.assigns.current_user.id,
        new_page,
        @page_per
      )

    socket
    |> assign(:page, new_page)
    |> assign(:total_pages, new_total_pages)
    |> assign(:notifications, new_notifications)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("next_button_click", _params, socket) do
    new_page = socket.assigns.page + 1

    %{entries: new_notifications, total_pages: new_total_pages} =
      get_notifications(
        socket.assigns.current_user.id,
        new_page,
        @page_per
      )

    socket
    |> assign(:page, new_page)
    |> assign(:total_pages, new_total_pages)
    |> assign(:notifications, new_notifications)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("confirm_notification", %{"notification_community_id" => id} = _params, socket) do
    notification = find_notification(socket.assigns.notifications, id)

    socket
    |> assign(:shown_notification_community, notification)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    %{entries: new_notifications, total_pages: new_total_pages} =
      get_notifications(
        socket.assigns.current_user.id,
        socket.assigns.page,
        @page_per
      )

    socket
    |> assign(:shown_notification_community, nil)
    |> assign(:total_pages, new_total_pages)
    |> assign(:notifications, new_notifications)
    |> then(&{:noreply, &1})
  end

  # ---private---

  defp get_notifications(user_id, page, per) do
    Notifications.list_notification_by_type(
      user_id,
      "community",
      page: page,
      page_size: per
    )
  end

  defp find_notification(notifications, notification_community_id) do
    Enum.find(notifications, &(&1.id == notification_community_id))
  end
end