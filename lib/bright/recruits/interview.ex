defmodule Bright.Recruits.Interview do
  @moduledoc """
  面談調整

  ユーザー検索画面から作成できる
  面談調整画面から一覧する
  チャットを開始できる
  面談を決定状態にすることで次の採用検討フェーズに進む
  """

  use Ecto.Schema
  alias Bright.Accounts.User
  alias Bright.Recruits.InterviewMember
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "interviews" do
    field :skill_panel_name, :string
    field :desired_income, :integer
    field :comment, :string
    field :skill_params, :string
    field :cancel_reason, :string

    field :status, Ecto.Enum,
      values: [
        :waiting_decision,
        :consume_interview,
        :dismiss_interview,
        :ongoing_interview,
        :completed_interview,
        :cancel_interview,
        :close_chat
      ],
      default: :waiting_decision

    field :recruiter_user_name, :string, virtual: true
    field :recruiter_user_icon, :string, virtual: true
    field :candidates_user_name, :string, virtual: true
    field :candidates_user_icon, :string, virtual: true
    field :is_read?, :boolean, virtual: true

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
      :skill_panel_name,
      :desired_income,
      :skill_params,
      :status,
      :comment,
      :candidates_user_id,
      :recruiter_user_id,
      :requestor_user_id,
      :cancel_reason
    ])
    |> cast_assoc(:interview_members,
      with: &InterviewMember.changeset/2
    )
    |> validate_required([:skill_params, :status, :candidates_user_id, :recruiter_user_id])
    |> validate_length(:skill_panel_name, max: 255)
    |> validate_length(:comment, max: 255)
  end

  def anon?(interview) do
    !(interview.status in [:ongoing_interview, :completed_interview])
  end
end
