defmodule Bright.Notifications.NotificationSkillUpdate do
  @moduledoc """
  The NotificationSkillUpdate context.
  """
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Bright.Accounts.User
  alias Bright.Notifications.NotificationSkillUpdate

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "notification_skill_updates" do
    field :message, :string
    field :url, :string

    belongs_to :from_user, User
    belongs_to :to_user, User

    timestamps()
  end

  @doc false
  def changeset(notification_skill_update, attrs) do
    notification_skill_update
    |> cast(attrs, [:from_user_id, :to_user_id, :message, :url])
    |> validate_required([:from_user_id, :to_user_id, :message, :url])
  end

  @doc """
  特定日付以降に更新された通知を取得するクエリ
  """
  def new_notifications_query(user_id, last_viewed_at) do
    from(notification_skill_update in NotificationSkillUpdate,
      where:
        notification_skill_update.to_user_id == ^user_id and
          notification_skill_update.updated_at > ^last_viewed_at
    )
  end
end
