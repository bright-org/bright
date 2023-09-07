defmodule Bright.Notifications.NotificationOfficialTeam do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notification_official_teams" do
    field :message, :string
    field :detail, :string
    field :from_user_id, Ecto.UUID
    field :to_user_id, Ecto.UUID
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
