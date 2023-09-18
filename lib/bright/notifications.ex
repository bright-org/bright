defmodule Bright.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Notifications.NotificationOperation
  alias Bright.Notifications.NotificationCommunity


  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!("operation", 123)
      %{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!("operation", id),
    do: Repo.get!(NotificationOperation, id)

  def get_notification!(_type, id),
    do: Repo.get!(Notification, id) |> Repo.preload([:from_user, :to_user])

  @doc """
  Returns the list of notifications by type.

   ## Examples

      iex> list_notification_by_type(user.id, "recruitment_coordination")
      %Notification{}
  """
  def list_notification_by_type(_to_user_id, "operation", page_param) do
    from(notification_operation in NotificationOperation,
      order_by: [desc: notification_operation.inserted_at]
    )
    |> Repo.paginate(page_param)
  end

  def list_notification_by_type(_to_user_id, "community", page_param) do
    from(notification_operation in NotificationCommunity,
      order_by: [desc: notification_operation.inserted_at]
    )
    |> Repo.paginate(page_param)
  end

  # TODO Notification廃止後に削除予定
  def list_notification_by_type(_to_user_id, _type, _page_param) do
    %Scrivener.Page{
      page_number: 1,
      page_size: 5,
      total_entries: 0,
      total_pages: 0,
      entries: []
    }
  end
end
