defmodule Bright.Communities.Community do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.Accounts.User
  alias Bright.Notifications.NotificationCommunity

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "communities" do
    field :name, :string
    belongs_to :user, User
    belongs_to :community, NotificationCommunity
    field :participation, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(community, attrs) do
    community
    |> cast(attrs, [:user_id, :community_id, :name, :participation])
    |> validate_required([:user_id, :community_id, :name, :participation])
  end
end
