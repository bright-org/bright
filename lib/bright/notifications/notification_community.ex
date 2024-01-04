defmodule Bright.Notifications.NotificationCommunity do
  @moduledoc """
  The NotificationCommunity context.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Bright.Accounts.User
  alias Bright.Notifications.NotificationCommunity

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "notification_communities" do
    field :message, :string
    field :detail, :string

    belongs_to :from_user, User

    timestamps()
  end

  @doc false
  def changeset(notification_community, attrs) do
    notification_community
    |> cast(attrs, [:from_user_id, :message, :detail])
    |> validate_required([:from_user_id, :message, :detail])
  end

  @doc """
  特定日付以降に更新された通知を取得するクエリ
  """
  def new_notifications_query(last_viewed_at) do
    from(notification_community in NotificationCommunity,
      where: notification_community.updated_at > ^last_viewed_at
    )
  end
end
