defmodule Bright.Teams.TeamMemberUsers do
  @moduledoc """
  チームに直接参加しているユーザーのリレーション、およびチーム・ユーザー単位で保有するチームの設定を管理するスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  @hash_algorithm :sha256
  @rand_size 32
  @invitation_validity_in_days 7

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "team_member_users" do
    field :is_admin, :boolean, default: false
    field :is_primary, :boolean, default: false
    field(:invitation_token, :binary)
    field :invitation_sent_to, :string
    field :invitation_confirmed_at, :naive_datetime

    belongs_to :team, Bright.Teams.Team

    field :user_id, Ecto.ULID

    timestamps()
  end

  @doc false
  def changeset(team_member_users, attrs) do
    team_member_users
    |> cast(attrs, [:user_id, :team_id, :is_admin, :is_primary, :invitation_token])
    |> validate_required([:user_id])
  end

  def build_invitation_token(member_user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    Base.url_encode64(token, padding: false)
  end

  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = @invitation_validity_in_days

        #query =
        #  from(membet_users in ,
        #    join: user in assoc(membet_users, :user),
        #   # where: membet_users.inserted_at > ago(^days, "day") and token.sent_to == user.email,
        #    select: membet_users
        #  )
          query = ""

        {:ok, query}

      :error ->
        :error
    end
  end
end
