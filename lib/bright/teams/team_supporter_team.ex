defmodule Bright.Teams.TeamSupporterTeam do
  @moduledoc """
  採用・人材支援を関係を扱うスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "team_supporter_teams" do
    field :end_datetime, :naive_datetime
    field :request_datetime, :naive_datetime
    field :start_datetime, :naive_datetime
    field :status, Ecto.Enum, values: [:requesting, :supporting, :support_ended, :reject]

    belongs_to :supportee_team, Bright.Teams.Team, references: :id
    belongs_to :supporter_team, Bright.Teams.Team, references: :id
    belongs_to :request_from_user, Bright.Accounts.User, references: :id
    belongs_to :request_to_user, Bright.Accounts.User, references: :id

    timestamps()
  end

  @doc false
  def create_changeset(team_supporter_team, attrs) do
    team_supporter_team
    |> cast(attrs, [
      :supportee_team_id,
      :supporter_team_id,
      :request_from_user_id,
      :request_to_user_id,
      :status,
      :request_datetime,
      :start_datetime,
      :end_datetime
    ])
    |> validate_required([:supportee_team_id, :request_from_user_id, :request_to_user_id, :status])
  end

  def update_changeset(team_supporter_team, attrs) do
    team_supporter_team
    |> cast(attrs, [
      :status,
      :start_datetime,
      :supporter_team_id,
      :end_datetime
    ])
    |> validate_required([:status])
  end
end
