defmodule Bright.Recruits.TeamJoinRequest do
  @moduledoc """
  候補者のチーム招待依頼

  採用候補者が採用を受諾後作成可能になる
  採用調整画面から一覧できる
  関わっているユーザーのチーム管理者に対して、依頼を行う
  依頼を行った後は採用担当者のアクションは終了となる
  """

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
