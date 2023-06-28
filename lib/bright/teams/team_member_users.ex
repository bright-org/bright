defmodule Bright.Teams.TeamMemberUsers do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "team_member_users" do
    field :is_admin, :boolean, default: false
    field :is_primary, :boolean, default: false
    # field :team_id, Ecto.UUID

    belongs_to :team, Bright.Teams.Team

    field :user_id, Ecto.ULID
    # TODO Userに直接association張るか検討
    # has_one :user, Bright.Accounts.User , references: :id

    timestamps()
  end

  @doc false
  def changeset(team_member_users, attrs) do
    team_member_users
    |> cast(attrs, [:user_id, :team_id, :is_admin, :is_primary])
    #|> cast(attrs, [:team_id, :is_admin, :is_primary])
    |> validate_required([:user_id])
    #|> validate_required([:team_id])
    #|> cast_assoc(:user, with: &Bright.Accounts.User.registration_changeset/2)
  end
end
