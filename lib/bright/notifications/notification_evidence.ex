defmodule Bright.Notifications.NotificationEvidence do
  @moduledoc """
  The NotificationEvidence context.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.Accounts.User

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "notification_evidences" do
    field :message, :string
    field :url, :string

    belongs_to :from_user, User
    belongs_to :to_user, User

    timestamps()
  end

  @doc false
  def changeset(notification_evidence, attrs) do
    notification_evidence
    |> cast(attrs, [:from_user_id, :to_user_id, :message, :url])
    |> validate_required([:from_user_id, :to_user_id, :message, :url])
  end
end
