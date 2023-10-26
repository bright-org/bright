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
    field :deleted_at, :naive_datetime

    has_many :member_users, Bright.Teams.TeamMemberUsers, on_replace: :delete
    has_many :users, through: [:member_users, :user]

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :enable_hr_functions, :enable_team_up_functions, :deleted_at])
  end

  @doc false
  def registration_changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :enable_hr_functions, :enable_team_up_functions, :deleted_at])
    |> validate_required([:name])
    |> validate_name()
  end

  @doc false
  defp validate_name(changeset) do
    changeset
    |> validate_length(:name, max: 255)
  end
end
