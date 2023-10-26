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

  Notice:

  This function returns in the order by inserted_at first, and id second.
  Without this rule, when inserted_at has same value, the order is not guaranteed.

   ## Examples

      iex> list_notification_by_type(user.id, "recruitment_coordination")
      %Notification{}
  """
  def list_notification_by_type(_to_user_id, "operation", page_param) do
    from(notification_operation in NotificationOperation,
      order_by: [
        desc: notification_operation.inserted_at,
        desc: notification_operation.id
      ]
    )
    |> Repo.paginate(page_param)
  end

  def list_notification_by_type(_to_user_id, "community", page_param) do
    from(notification_community in NotificationCommunity,
      order_by: [
        desc: notification_community.inserted_at,
        desc: notification_community.id
      ]
    )
    |> Repo.paginate(page_param)
  end

  @doc """
  Confirm a notification.

  ## Examples

      iex> confirm_notification!(%NotificationOperation{})
      %NotificationOperation{}

      iex> confirm_notification!(%NotificationOperation{})
      nil

      iex> confirm_notification!(%NotificationCommunity{})
      %NotificationCommunity{}

      iex> confirm_notification!(%NotificationCommunity{})
      ** (Ecto.NoResultsError)

  """
  def confirm_notification!(
        %NotificationOperation{confirmed_at: nil} = notification
      ) do
    Ecto.Changeset.change(notification,
      confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    )
    |> Repo.update!()
  end

  def confirm_notification!(_notification) do
    nil
  end

  @doc """
  Returns the number of unconfirmed notifications by user.

  ## Examples

      iex> list_unconfirmed_notification_count(user)
      %{
        "operation" => 1
      }
  """
  # TODO: テスト
  def list_unconfirmed_notification_count(%User{} = _user) do
    %{
      "operation" => not_confirmed_notification_operation_count()
    }
  end

  # NOTE: 運営からの通知は to_user_id がないので、引数に user 不要
  defp not_confirmed_notification_operation_count do
    NotificationOperation.not_confirmed_query() |> Repo.aggregate(:count)
  end
end
