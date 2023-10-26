defmodule Bright.Notifications.NotificationOperation do
  @moduledoc """
  The NotificationOperation context.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Bright.Accounts.User

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "notification_operations" do
    field :message, :string
    belongs_to :from_user, User
    field :detail, :string
    field :confirmed_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(notification_operation, attrs) do
    notification_operation
    |> cast(attrs, [:from_user_id, :message, :detail])
    |> validate_required([:from_user_id, :message, :detail])
  end

  @doc """
  Returns the query for not confirmed notifications.
  """
  def not_confirmed_query do
    from(notification_operation in Bright.Notifications.NotificationOperation,
      where: is_nil(notification_operation.confirmed_at)
    )
  end
end
