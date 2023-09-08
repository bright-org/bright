defmodule Bright.Notifications.NotificationOfficialTeam do
  @moduledoc """
  The NotificationOfficialTeam context.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.Accounts.User

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "notification_official_teams" do
    field :message, :string
    field :detail, :string
    belongs_to :from_user, User
    belongs_to :to_user, User
    field :participation, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(notification_official_team, attrs) do
    notification_official_team
    |> cast(attrs, [:from_user_id, :to_user_id, :message, :detail, :participation])
    |> validate_required([:from_user_id, :to_user_id, :message, :detail, :participation])
  end
end
