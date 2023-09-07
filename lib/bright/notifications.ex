defmodule Bright.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Notifications.Notification
  alias Bright.Notifications.NotificationOperation

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications do
    Repo.all(Notification)
    |> Repo.preload([:from_user, :to_user])
  end

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

  # TODO Notification廃止後に削除予定
  def list_notification_by_type(to_user_id, type, page_param) do
    type_query(to_user_id, type)
    |> Repo.paginate(page_param)
  end

  defp type_query(to_user_id, type) do
    from n in Notification,
      where:
        n.to_user_id == ^to_user_id and
          n.type == ^type,
      order_by: [desc: n.inserted_at]
  end

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{data: %Notification{}}

  """
  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end

  alias Bright.Notifications.NotificationOfficialTeam

  @doc """
  Returns the list of notification_official_teams.

  ## Examples

      iex> list_notification_official_teams()
      [%NotificationOfficialTeam{}, ...]

  """
  def list_notification_official_teams do
    Repo.all(NotificationOfficialTeam)
  end

  @doc """
  Gets a single notification_official_team.

  Raises `Ecto.NoResultsError` if the Notification official team does not exist.

  ## Examples

      iex> get_notification_official_team!(123)
      %NotificationOfficialTeam{}

      iex> get_notification_official_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification_official_team!(id), do: Repo.get!(NotificationOfficialTeam, id)

  @doc """
  Creates a notification_official_team.

  ## Examples

      iex> create_notification_official_team(%{field: value})
      {:ok, %NotificationOfficialTeam{}}

      iex> create_notification_official_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification_official_team(attrs \\ %{}) do
    %NotificationOfficialTeam{}
    |> NotificationOfficialTeam.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification_official_team.

  ## Examples

      iex> update_notification_official_team(notification_official_team, %{field: new_value})
      {:ok, %NotificationOfficialTeam{}}

      iex> update_notification_official_team(notification_official_team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification_official_team(%NotificationOfficialTeam{} = notification_official_team, attrs) do
    notification_official_team
    |> NotificationOfficialTeam.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification_official_team.

  ## Examples

      iex> delete_notification_official_team(notification_official_team)
      {:ok, %NotificationOfficialTeam{}}

      iex> delete_notification_official_team(notification_official_team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification_official_team(%NotificationOfficialTeam{} = notification_official_team) do
    Repo.delete(notification_official_team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification_official_team changes.

  ## Examples

      iex> change_notification_official_team(notification_official_team)
      %Ecto.Changeset{data: %NotificationOfficialTeam{}}

  """
  def change_notification_official_team(%NotificationOfficialTeam{} = notification_official_team, attrs \\ %{}) do
    NotificationOfficialTeam.changeset(notification_official_team, attrs)
  end
end
