defmodule Bright.Recruits.Interview do
  use Ecto.Schema
  alias Bright.Accounts.User
  alias Bright.Recruits.InterviewMember
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "interviews" do
    field :comment, :string
    field :skill_params, :string

    field :status, Ecto.Enum,
      values: [:waiting_deceision, :consume_interview, :dismiss_interview, :completed_interview]

    belongs_to :candidates_user, User
    belongs_to :recruiter_user, User
    belongs_to :requestor_user, User

    has_many :interview_members, InterviewMember, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(interview, attrs) do
    interview
    |> cast(attrs, [
      :skill_params,
      :status,
      :comment,
      :candidates_user_id,
      :recruiter_user_id,
      :requestor_user_id
    ])
    |> cast_assoc(:interview_members,
      with: &InterviewMember.changeset/2
    )
    |> validate_required([:skill_params, :status, :candidates_user_id, :recruiter_user_id])
  end
end
