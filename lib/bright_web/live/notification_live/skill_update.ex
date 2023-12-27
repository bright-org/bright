defmodule BrightWeb.NotificationLive.SkillUpdate do
  use BrightWeb, :live_view

  alias Bright.Notifications
  alias BrightWeb.CardLive.CardListComponents
  alias BrightWeb.TabComponents

  @default_page 1
  @page_per 10

  @impl true
  def render(assigns) do
    ~H"""
    <div id="notification_skill_update_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">
        <li :if={Enum.count(@notifications) == 0} class="flex">
          <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
            スキルアップの通知はありません
          </div>
        </li>
        <%= for notification <- @notifications do %>
          <li class="flex flex-wrap my-5">
            <div phx-click="click" phx-value-notification_skill_update_id={notification.id} class="cursor-pointer hover:opacity-70 text-left flex flex-wrap items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap">
              <span class="material-icons text-lg text-white bg-brightGreen-300 rounded-full flex w-6 h-6 mr-2.5 items-center justify-center">
                person
              </span>
              <span class={["order-3 lg:order-2 flex-1 mr-2"]}><%= notification.message %></span>
              <CardListComponents.elapsed_time inserted_at={notification.inserted_at} />
            </div>
            <div class="flex gap-x-2 w-full justify-end lg:justify-start lg:w-auto">
              <button phx-click="click" phx-value-notification_skill_update_id={notification.id} class="hidden hover:opacity-70 font-bold lg:inline-block bg-brightGray-900 text-white min-w-[76px] rounded p-2 text-sm">
                詳細を見る
              </button>
            </div>
          </li>
        <% end %>
        <TabComponents.tab_footer id="notification_skill_update_footer" page={@page} total_pages={@total_pages} target={"#notification_skill_update_container"} />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "スキルアップの通知")
    |> assign_on_page(@default_page)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("previous_button_click", _params, socket) do
    socket
    |> assign_on_page(socket.assigns.page - 1)
    |> then(&{:noreply, &1})
  end

  def handle_event("next_button_click", _params, socket) do
    socket
    |> assign_on_page(socket.assigns.page + 1)
    |> then(&{:noreply, &1})
  end

  def handle_event("click", %{"notification_skill_update_id" => id} = _params, socket) do
    notification = find_notification(socket.assigns.notifications, id)

    socket
    |> push_navigate(to: notification.url)
    |> then(&{:noreply, &1})
  end

  # ---private---

  defp get_notifications(user_id, page, per) do
    Notifications.list_notification_by_type(
      user_id,
      "skill_update",
      page: page,
      page_size: per
    )
  end

  defp find_notification(notifications, notification_skill_update_id) do
    Enum.find(notifications, &(&1.id == notification_skill_update_id))
  end

  defp assign_on_page(socket, page) do
    %{entries: notifications, total_pages: total_pages} =
      get_notifications(socket.assigns.current_user.id, page, @page_per)

    socket
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
    |> assign(:notifications, notifications)
  end
end
