defmodule BrightWeb.Api.NotificationOperationJSON do
  alias Bright.Notifications.NotificationOperation

  @doc """
  Renders a list of notification_operations.
  """
  def index(%{notification_operations: notification_operations}) do
    %{
      data:
        for(notification_operation <- notification_operations, do: data(notification_operation))
    }
  end

  @doc """
  Renders a single notification_operation.
  """
  def show(%{notification_operation: notification_operation}) do
    %{data: data(notification_operation)}
  end

  defp data(%NotificationOperation{} = notification_operation) do
    %{
      id: notification_operation.id,
      from_user_id: notification_operation.from_user_id,
      message: notification_operation.message,
      detail: notification_operation.detail
    }
  end
end
