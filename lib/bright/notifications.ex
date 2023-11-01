defmodule Bright.Notifications do
  @moduledoc """
  The Notifications context.

  通知周りの処理を集約するコンテキストです
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Notifications.NotificationOperation
  alias Bright.Notifications.NotificationCommunity
  alias Bright.Accounts.User

  @doc """
  Returns the list of all notifications by type.

  ## Examples

      iex> list_all_notifications("operation")
      [%NotificationOperation{}, ...]

  """
  def list_all_notifications("operation") do
    Repo.all(NotificationOperation)
  end

  def list_all_notifications("community") do
    Repo.all(NotificationCommunity)
  end

  @doc """
  Gets a single notification by type.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!("operation", 123)
      %{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!("operation", id),
    do: Repo.get!(NotificationOperation, id)

  def get_notification!("community", id),
    do: Repo.get!(NotificationCommunity, id)

  @doc """
  Returns the list of notifications by type order by id.

  Notice:

  This function returns in the order by id DESC.

  We use ULID as id, so id sort is same as inserted_at sort.
  https://github.com/woylie/ecto_ulid/blob/v1.0.1/README.md

   ## Examples

      iex> list_notification_by_type(user.id, "recruitment_coordination", [page: 1, page_size: 10])
      %Notification{}
  """
  def list_notification_by_type(_to_user_id, "operation", page_param) do
    from(notification_operation in NotificationOperation,
      order_by: [
        desc: notification_operation.id
      ]
    )
    |> Repo.paginate(page_param)
  end

  def list_notification_by_type(_to_user_id, "community", page_param) do
    from(notification_community in NotificationCommunity,
      order_by: [
        desc: notification_community.id
      ]
    )
    |> Repo.paginate(page_param)
  end

  @doc """
  Creates a notification by type.

  ## Examples

      iex> create_notification("operation", %{field: value})
      {:ok, %NotificationOperation{}}

      iex> create_notification("operation", %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(notification_type, attrs \\ %{})

  def create_notification("operation", attrs) do
    %NotificationOperation{}
    |> NotificationOperation.changeset(attrs)
    |> Repo.insert()
  end

  def create_notification("community", attrs) do
    %NotificationCommunity{}
    |> NotificationCommunity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification by type.

  ## Examples

      iex> update_notification(notification_operation, %{field: new_value})
      {:ok, %NotificationOperation{}}

      iex> update_notification(notification_operation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%NotificationOperation{} = notification_operation, attrs) do
    notification_operation
    |> NotificationOperation.changeset(attrs)
    |> Repo.update()
  end

  def update_notification(%NotificationCommunity{} = notification_community, attrs) do
    notification_community
    |> NotificationCommunity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification by type.

  ## Examples

      iex> delete_notification(notification_operation)
      {:ok, %NotificationOperation{}}

      iex> delete_notification(notification_operation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%NotificationOperation{} = notification_operation) do
    Repo.delete(notification_operation)
  end

  def delete_notification(%NotificationCommunity{} = notification_community) do
    Repo.delete(notification_community)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes by type.

  ## Examples

      iex> change_notification(notification_operation)
      %Ecto.Changeset{data: %NotificationOperation{}}

  """
  def change_notification(notification_type, attrs \\ %{})

  def change_notification(
        %NotificationOperation{} = notification_operation,
        attrs
      ) do
    NotificationOperation.changeset(notification_operation, attrs)
  end

  def change_notification(
        %NotificationCommunity{} = notification_community,
        attrs
      ) do
    NotificationCommunity.changeset(notification_community, attrs)
  end
end
