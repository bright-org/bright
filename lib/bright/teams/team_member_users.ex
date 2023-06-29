defmodule Bright.Teams.TeamMemberUsers do
  @moduledoc """
  チームに直接参加しているユーザーのリレーション、およびチーム・ユーザー単位で保有するチームの設定を管理するスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "team_member_users" do
    field :is_admin, :boolean, default: false
    field :is_primary, :boolean, default: false

    belongs_to :team, Bright.Teams.Team

    field :user_id, Ecto.ULID

    timestamps()
  end

  @doc false
  def changeset(team_member_users, attrs) do
    team_member_users
    |> cast(attrs, [:user_id, :team_id, :is_admin, :is_primary])
    |> validate_required([:user_id])
  end
end
