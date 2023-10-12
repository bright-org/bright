defmodule Bright.NotificationOperations do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Notifications.NotificationOperation

  @doc """
  Returns the list of notification_operations.

  ## Examples

      iex> list_notification_operations()
      [%NotificationOperation{}, ...]

  """
  def list_notification_operations do
    Repo.all(NotificationOperation)
  end

  @doc """
  Gets a single notification_operation.

  Raises `Ecto.NoResultsError` if the Notification operation does not exist.

  ## Examples

      iex> get_notification_operation!(123)
      %NotificationOperation{}

      iex> get_notification_operation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification_operation!(id), do: Repo.get!(NotificationOperation, id)

  @doc """
  Creates a notification_operation.

  ## Examples

      iex> create_notification_operation(%{field: value})
      {:ok, %NotificationOperation{}}

      iex> create_notification_operation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification_operation(attrs \\ %{}) do
    %NotificationOperation{}
    |> NotificationOperation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification_operation.

  ## Examples

      iex> update_notification_operation(notification_operation, %{field: new_value})
      {:ok, %NotificationOperation{}}

      iex> update_notification_operation(notification_operation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification_operation(%NotificationOperation{} = notification_operation, attrs) do
    notification_operation
    |> NotificationOperation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification_operation.

  ## Examples

      iex> delete_notification_operation(notification_operation)
      {:ok, %NotificationOperation{}}

      iex> delete_notification_operation(notification_operation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification_operation(%NotificationOperation{} = notification_operation) do
    Repo.delete(notification_operation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification_operation changes.

  ## Examples

      iex> change_notification_operation(notification_operation)
      %Ecto.Changeset{data: %NotificationOperation{}}

  """
  def change_notification_operation(
        %NotificationOperation{} = notification_operation,
        attrs \\ %{}
      ) do
    NotificationOperation.changeset(notification_operation, attrs)
  end
end
