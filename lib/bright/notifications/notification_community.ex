defmodule Bright.Notifications.NotificationCommunity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notification_communities" do
    field :message, :string
    field :from_user_id, Ecto.UUID
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
