defmodule Bright.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "teams" do
    field :name, :string
    field :enable_hr_functions, :boolean, default: false

    # has_many :users, Bright.Accounts.User , join_through: Bright.Teams.UserJoinedTeam
    has_many :member_users, Bright.Teams.TeamMemberUsers

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :enable_hr_functions])
    |> validate_required([:name, :enable_hr_functions])
  end
end
