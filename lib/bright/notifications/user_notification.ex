defmodule Bright.Notifications.UserNotification do
  @moduledoc """
  ユーザーの通知管理
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.Accounts.User

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "user_notifications" do
    field :last_viewed_at, :naive_datetime

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(user_notification, attrs) do
    user_notification
    |> cast(attrs, [:user_id, :last_viewed_at])
    |> validate_required([:user_id, :last_viewed_at])
  end
end
