defmodule BrightWeb.MypageLive.NotificationDetailComponent do
  @moduledoc """
  Notification Detail Components
  """
  use BrightWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header> <%= @notification.message %> </.header>
      <div class="flex justify-between items-center my-2 gap-x-4">
        <%= Phoenix.HTML.Format.text_to_html @notification.detail || "", attributes: [class: "break-all grow"] %>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:notification, get_notification(assigns))

    {:ok, socket}
  end

  def get_notification(%{notification_type: "operation" = type, notification_id: notification_id}) do
    # TODO 仮実装 新しい通知テーブル作成後に実装する
    Bright.Notifications.get_notification!(type, notification_id)
  end

  def get_notification(_), do: %{message: "", detail: ""}
end
