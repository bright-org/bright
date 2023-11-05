defmodule Bright.Recruits.Interview do
  use Ecto.Schema
  alias Bright.Accounts.User
  alias Bright.Recruits.InterviewMember
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "recruit_interviews" do
    field :comment, :string
    field :skill_params, :string
    field :status, :string

    belongs_to :recruitment_candidates_user, User
    belongs_to :recruiter, User
    belongs_to :requester, User

    has_many :interview_members, InterviewMember,
      on_replace: :delete,
      foreign_key: :recruit_interview_id

    timestamps()
  end

  @doc false
  def changeset(interview, attrs) do
    interview
    |> cast(attrs, [
      :skill_params,
      :status,
      :comment,
      :recruitment_candidates_user_id,
      :recruiter_id,
      :requester_id
    ])
    |> cast_assoc(:interview_members,
      with: &InterviewMember.changeset/2
    )
    |> validate_required([:skill_params, :status, :recruitment_candidates_user_id, :recruiter_id])
  end
end
