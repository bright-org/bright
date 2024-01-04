defmodule Bright.Notifications.NotificationOperation do
  @moduledoc """
  The NotificationOperation context.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Bright.Accounts.User
  alias Bright.Notifications.NotificationOperation

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "notification_operations" do
    field :message, :string
    field :detail, :string

    belongs_to :from_user, User

    timestamps()
  end

  @doc false
  def changeset(notification_operation, attrs) do
    notification_operation
    |> cast(attrs, [:from_user_id, :message, :detail])
    |> validate_required([:from_user_id, :message, :detail])
  end

  @doc """
  特定日付以降に更新された通知を取得するクエリ
  """
  def new_notifications_query(last_viewed_at) do
    from(notificaiton_operation in NotificationOperation,
      where: notificaiton_operation.updated_at > ^last_viewed_at
    )
  end
end
