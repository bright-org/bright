defmodule Bright.Teams.Team do
  @moduledoc """
  チームを扱うスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "teams" do
    field :name, :string
    field :enable_hr_functions, :boolean, default: false
    field :enable_team_up_functions, :boolean, default: false
    field :disabled_at, :naive_datetime

    has_many :member_users, Bright.Teams.TeamMemberUsers, on_replace: :delete
    has_many :users, through: [:member_users, :user]

    has_many :team_supporter_teams_on_supporter, Bright.Teams.TeamSupporterTeam,
      foreign_key: :supporter_team_id

    has_many :team_supporter_teams_on_supportee, Bright.Teams.TeamSupporterTeam,
      foreign_key: :supportee_team_id

    many_to_many :supportee_teams_supporting,
                 Bright.Teams.Team,
                 join_through: Bright.Teams.TeamSupporterTeam,
                 join_keys: [supporter_team_id: :id, supportee_team_id: :id],
                 join_where: [status: :supporting]

    many_to_many :supporter_teams_supporting,
                 Bright.Teams.Team,
                 join_through: Bright.Teams.TeamSupporterTeam,
                 join_keys: [supportee_team_id: :id, supporter_team_id: :id],
                 join_where: [status: :supporting]

    field :default_skill_panel_id, Ecto.ULID

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :enable_hr_functions, :enable_team_up_functions, :disabled_at])
  end

  @doc false
  def registration_changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :enable_hr_functions, :enable_team_up_functions, :disabled_at])
    |> validate_required([:name])
    |> validate_name()
  end

  @doc false
  defp validate_name(changeset) do
    changeset
    |> validate_length(:name, max: 255)
  end
end
