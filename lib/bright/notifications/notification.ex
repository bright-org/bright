defmodule Bright.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :message, :string
    field :type, :string
    field :url, :string
    field :from_user_id, Ecto.UUID
    field :to_user_id, Ecto.UUID
    field :icon_type, :string
    field :read_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:from_user_id, :to_user_id, :icon_type, :message, :type, :url, :read_at])
    |> validate_required([:from_user_id, :to_user_id, :icon_type, :message, :type, :url, :read_at])
  end
end
