defmodule Bright.NotificationOperation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notification_operations" do
    field :message, :string
    field :from_user_id, Ecto.UUID
    field :detail, :string

    timestamps()
  end

  @doc false
  def changeset(notification_operation, attrs) do
    notification_operation
    |> cast(attrs, [:from_user_id, :message, :detail])
    |> validate_required([:from_user_id, :message, :detail])
  end
end
