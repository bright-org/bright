defmodule Bright.Recruits.CoordinationMember do
  @moduledoc """
  採用調整参加者候補
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "coordination_members" do
    field :decision, Ecto.Enum,
      values: [:not_answered, :recruit_wants, :recruit_keep, :recruit_not_wants],
      default: :not_answered

    belongs_to :user, Bright.Accounts.User
    belongs_to :coordination, Bright.Recruits.Coordination

    timestamps()
  end

  @doc false
  def changeset(coordination_member, attrs) do
    coordination_member
    |> cast(attrs, [:decision, :user_id, :coordination_id])
    |> validate_required([:user_id])
  end
end
