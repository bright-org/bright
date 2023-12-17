defmodule Bright.Notifications.NotificationEvidence do
  @moduledoc """
  The NotificationEvidence context.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Bright.Accounts.User
  alias Bright.Notifications.NotificationEvidence

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

  @doc """
  特定日付以降に更新された通知を取得するクエリ
  """
  def new_notifications_query(user_id, last_viewed_at) do
    from(notification_evidence in NotificationEvidence,
      where:
        notification_evidence.to_user_id == ^user_id and
          notification_evidence.updated_at > ^last_viewed_at
    )
  end
end
