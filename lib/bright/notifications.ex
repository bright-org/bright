defmodule Bright.Notifications do
  @moduledoc """
  The Notifications context.

  通知周りの処理を集約するコンテキストです
  """

  import Ecto.Query, warn: false

  alias Bright.Repo
  alias Bright.Accounts.User

  alias Bright.Notifications.{
    NotificationOperation,
    NotificationCommunity,
    NotificationEvidence,
    NotificationSkillUpdate,
    UserNotification
  }

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
      %Scrivener.Page{}
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

  def list_notification_by_type(to_user_id, "evidence", page_param) do
    from(notification_evidence in NotificationEvidence,
      where: notification_evidence.to_user_id == ^to_user_id,
      order_by: [
        desc: notification_evidence.id
      ]
    )
    |> Repo.paginate(page_param)
  end

  def list_notification_by_type(to_user_id, "skill_update", page_param) do
    from(notification_skill_update in NotificationSkillUpdate,
      where: notification_skill_update.to_user_id == ^to_user_id,
      order_by: [
        desc: notification_skill_update.id
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

  def create_notification("evidence", attrs) do
    %NotificationEvidence{}
    |> NotificationEvidence.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a notifications by type.
  """
  def create_notifications("evidence", attrs_list) do
    Repo.insert_all(NotificationEvidence, attrs_list)
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

  @doc """
  Returns whether the user has new notification or not.

  ## Examples

      iex> has_unread_notification?(user)
      true

  """
  def has_unread_notification?(%User{} = user) do
    user
    |> Repo.preload(:user_notification)
    |> Map.get(:user_notification)
    |> unread_notification_exists?()
  end

  defp unread_notification_exists?(nil), do: true

  defp unread_notification_exists?(
         %UserNotification{user_id: user_id, last_viewed_at: last_viewed_at} = _user_notification
       ) do
    NotificationOperation.new_notifications_query(last_viewed_at) |> Repo.exists?() ||
      NotificationCommunity.new_notifications_query(last_viewed_at) |> Repo.exists?() ||
      NotificationEvidence.new_notifications_query(user_id, last_viewed_at) |> Repo.exists?() ||
      NotificationSkillUpdate.new_notifications_query(user_id, last_viewed_at) |> Repo.exists?()
  end

  @doc """
  Create a user notification or Update last_viewed_at.

  ## Examples

      iex> view_notification(user)
      {:ok, %UserNotification{}}
  """
  def view_notification(%User{} = user) do
    user
    |> Repo.preload(:user_notification)
    |> Map.get(:user_notification)
    |> create_or_update_user_notification(user)
  end

  defp create_or_update_user_notification(nil, user) do
    %UserNotification{}
    |> UserNotification.changeset(%{user_id: user.id, last_viewed_at: DateTime.utc_now()})
    |> Repo.insert()
  end

  defp create_or_update_user_notification(user_notification, _user) do
    user_notification
    |> UserNotification.changeset(%{last_viewed_at: DateTime.utc_now()})
    |> Repo.update()
  end

  @doc """
  Returns related user_ids from user.
  """
  def list_related_user_ids(user) do
    # ユーザー所属チームとその関連チームに属するuser_idを取得
    # NOTE: 今後設定によって通知要否（粒度未定）できるようになる想定です。そのため個別ロードしています。
    teams =
      Ecto.assoc(user, :teams)
      |> preload([
        :member_users,
        supporter_teams_supporting: [:member_users],
        supportee_teams_supporting: [:member_users]
      ])
      |> Repo.all()

    # チームメンバー
    team_related_ids = collect_team_user_ids(teams)

    # 支援元メンバー
    supporter_related_ids =
      teams
      |> Enum.flat_map(& &1.supporter_teams_supporting)
      |> collect_team_user_ids()

    # 支援先メンバー
    supportee_related_ids =
      teams
      |> Enum.flat_map(& &1.supportee_teams_supporting)
      |> collect_team_user_ids()

    (team_related_ids ++ supporter_related_ids ++ supportee_related_ids)
    |> Enum.uniq()
    |> List.delete(user.id)
  end

  defp collect_team_user_ids(teams) do
    Enum.flat_map(teams, fn team ->
      Enum.map(team.member_users, & &1.user_id)
    end)
  end
end
