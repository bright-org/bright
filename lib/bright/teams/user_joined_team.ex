defmodule Bright.Teams.UserJoinedTeam do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_joined_teams" do


    field :is_auther, :boolean, default: false
    field :is_primary_team, :boolean, default: false

    ##field :team_id, :integer
    belongs_to :team, Bright.Teams.Team

    ##field :bright_user_id, :integer
    belongs_to :bright_user, Bright.Users

    timestamps()
  end

  @doc false
  def changeset(user_joined_team, attrs) do
    user_joined_team
    |> cast(attrs, [:bright_user_id, :team_id, :is_auther, :is_primary_team])
    |> validate_required([:bright_user_id, :team_id, :is_auther, :is_primary_team])
  end
end
