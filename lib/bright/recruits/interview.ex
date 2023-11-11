defmodule Bright.Recruits.Interview do
  @moduledoc """
  面談調整
  """

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
      values: [:waiting_decision, :consume_interview, :dismiss_interview, :completed_interview],
      default: :waiting_decision

    belongs_to :candidates_user, User
    belongs_to :recruiter_user, User
    belongs_to :requestor_user, User

    has_many :interview_members, InterviewMember, on_replace: :delete, on_delete: :delete_all

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

  def career_fields(interview, career_fields) do
    interview.skill_params
    |> Jason.decode!()
    |> Enum.map(&Map.get(&1, "career_field"))
    |> Enum.map(&Enum.find(career_fields, fn ca -> ca.name_en == &1 end))
    |> Enum.map_join(",", & &1.name_ja)
  end
end
