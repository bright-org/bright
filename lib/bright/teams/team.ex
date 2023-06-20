defmodule Bright.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :team_name, :string
    field :enable_hr_functions, :boolean, default: false
    #field :auther_bright_user_id, :integer
    belongs_to  :auther_bright_user, Bright.Users.BrightUser, references: :id

    many_to_many :brigit_users, Bright.Users.BrightUser , join_through: Bright.Teams.UserJoinedTeam

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:team_name, :enable_hr_functions, :auther_bright_user_id])
    |> validate_required([:team_name, :enable_hr_functions, :auther_bright_user_id])
  end
end
