defmodule Bright.Recruits.InterviewMember do
  @moduledoc """
  面談調整参加者候補
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "interview_members" do
    field :decision, Ecto.Enum,
      values: [:not_answered, :wants, :keep, :not_wants],
      default: :not_answered

    belongs_to :user, Bright.Accounts.User
    belongs_to :interview, Bright.Recruits.Interview

    timestamps()
  end

  @doc false
  def changeset(interview_member, attrs) do
    interview_member
    |> cast(attrs, [:decision, :user_id, :interview_id])
    |> validate_required([:user_id])
  end
end
