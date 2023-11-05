defmodule Bright.Recruits.InterviewMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "recruit_interview_members" do
    field :decision, :string

    belongs_to :user, Bright.Accounts.User, references: :id
    belongs_to :recruit_interview, Bright.Recruits.Interview

    timestamps()
  end

  @doc false
  def changeset(interview_member, attrs) do
    interview_member
    |> cast(attrs, [:decision, :user_id, :recruit_interview_id])
    |> validate_required([:user_id])
  end
end
