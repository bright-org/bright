defmodule Bright.Recruits.TeamJoinRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "team_join_requests" do
    field :comment, :string
    field :status, Ecto.Enum, values: [:requested, :invited, :cancel], default: :requested

    belongs_to :employment, Bright.Recruits.Employment
    belongs_to :team_owner_user, Bright.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(team_join_request, attrs) do
    team_join_request
    |> cast(attrs, [:status, :comment, :employment_id, :team_owner_user_id])
    |> validate_required([:status, :comment, :team_owner_user_id])
  end
end
