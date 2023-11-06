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
    field :status, :string

    belongs_to :candidates_user, User
    belongs_to :recruiter_user, User
    belongs_to :requester_user, User

    has_many :interview_members, InterviewMember,
      on_replace: :delete,
      foreign_key: :interview_id

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
      :requester_user_id
    ])
    |> cast_assoc(:interview_members,
      with: &InterviewMember.changeset/2
    )
    |> validate_required([:skill_params, :status, :candidates_user_id, :recruiter_user_id])
  end
end
