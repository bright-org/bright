defmodule Bright.Notifications.NotificationCommunity do
  @moduledoc """
  The NotificationCommunity context.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.Accounts.User

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "notification_communities" do
    field :message, :string
    belongs_to :from_user, User
    field :detail, :string

    timestamps()
  end

  @doc false
  def changeset(notification_community, attrs) do
    notification_community
    |> cast(attrs, [:from_user_id, :message, :detail])
    |> validate_required([:from_user_id, :message, :detail])
  end
end
