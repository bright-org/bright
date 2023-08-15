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
    belongs_to :user, Bright.Accounts.User, references: :id

    # has_many :user_skill_panels, Bright.SkillPanels.UserSkillPanel, join_through: "user_skill_panels", references: :user_id

    # field :user_id, Ecto.ULID

    timestamps()
  end

  @doc false
  def changeset(team_member_users, attrs) do
    team_member_users
    |> cast(attrs, [:user_id, :team_id, :is_admin, :is_primary])
    |> validate_required([:user_id])
  end
end
