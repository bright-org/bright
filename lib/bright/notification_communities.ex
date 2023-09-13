defmodule Bright.NotificationCommunities do
  @moduledoc """
  The NotificationCommunities context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Notifications.NotificationCommunity

  @doc """
  Returns the list of notification_communities.

  ## Examples

      iex> list_notification_communities()
      [%NotificationCommunity{}, ...]

  """
  def list_notification_communities do
    Repo.all(NotificationCommunity)
  end

  @doc """
  Gets a single notification_community.

  Raises `Ecto.NoResultsError` if the Notification community does not exist.

  ## Examples

      iex> get_notification_community!(123)
      %NotificationCommunity{}

      iex> get_notification_community!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification_community!(id), do: Repo.get!(NotificationCommunity, id)

  @doc """
  Creates a notification_community.

  ## Examples

      iex> create_notification_community(%{field: value})
      {:ok, %NotificationCommunity{}}

      iex> create_notification_community(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification_community(attrs \\ %{}) do
    %NotificationCommunity{}
    |> NotificationCommunity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification_community.

  ## Examples

      iex> update_notification_community(notification_community, %{field: new_value})
      {:ok, %NotificationCommunity{}}

      iex> update_notification_community(notification_community, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification_community(%NotificationCommunity{} = notification_community, attrs) do
    notification_community
    |> NotificationCommunity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification_community.

  ## Examples

      iex> delete_notification_community(notification_community)
      {:ok, %NotificationCommunity{}}

      iex> delete_notification_community(notification_community)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification_community(%NotificationCommunity{} = notification_community) do
    Repo.delete(notification_community)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification_community changes.

  ## Examples

      iex> change_notification_community(notification_community)
      %Ecto.Changeset{data: %NotificationCommunity{}}

  """
  def change_notification_community(%NotificationCommunity{} = notification_community, attrs \\ %{}) do
    NotificationCommunity.changeset(notification_community, attrs)
  end
end
