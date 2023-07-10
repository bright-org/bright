defmodule Bright.Notifications.Notification do
  @moduledoc """
  通知を扱うスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.Accounts.User

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "notifications" do
    field :message, :string
    field :type, :string
    field :url, :string
    belongs_to :from_user, User
    belongs_to :to_user, User
    field :icon_type, :string
    field :read_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:from_user_id, :to_user_id, :icon_type, :message, :type, :url, :read_at])
    |> validate_required([:from_user_id, :to_user_id, :icon_type, :message, :type])
  end
end
