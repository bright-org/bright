defmodule BrightWeb.Api.NotificationOperationController do
  use BrightWeb, :controller

  alias Bright.Notifications
  alias Bright.Notifications.NotificationOperation

  action_fallback BrightWeb.FallbackController

  def index(conn, _params) do
    notification_operations = Notifications.list_notification_operations()
    render(conn, :index, notification_operations: notification_operations)
  end

  def create(conn, %{"notification_operation" => notification_operation_params}) do
    with {:ok, %NotificationOperation{} = notification_operation} <-
           Notifications.create_notification_operation(notification_operation_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/v1/notification_operations/#{notification_operation}"
      )
      |> render(:show, notification_operation: notification_operation)
    end
  end

  def show(conn, %{"id" => id}) do
    notification_operation = Notifications.get_notification_operation!(id)
    render(conn, :show, notification_operation: notification_operation)
  end

  def update(conn, %{"id" => id, "notification_operation" => notification_operation_params}) do
    notification_operation = Notifications.get_notification_operation!(id)

    with {:ok, %NotificationOperation{} = notification_operation} <-
           Notifications.update_notification_operation(
             notification_operation,
             notification_operation_params
           ) do
      render(conn, :show, notification_operation: notification_operation)
    end
  end

  def delete(conn, %{"id" => id}) do
    notification_operation = Notifications.get_notification_operation!(id)

    with {:ok, %NotificationOperation{}} <-
           Notifications.delete_notification_operation(notification_operation) do
      send_resp(conn, :no_content, "")
    end
  end
end
