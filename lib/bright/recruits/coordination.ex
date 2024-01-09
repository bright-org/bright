defmodule Bright.Recruits.Coordination do
  @moduledoc """
  採用検討

  面談調整画面の面談決定状態の面談調整からモーダルを開き作成する
  採用選考画面から一覧できる
  選考結果の準備から採用調整フェーズに進む
  """

  use Ecto.Schema
  alias Bright.Accounts.User
  alias Bright.Recruits.CoordinationMember
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "coordinations" do
    field :skill_panel_name, :string
    field :desired_income, :integer
    field :comment, :string
    field :skill_params, :string
    field :cancel_reason, :string

    field :status, Ecto.Enum,
      values: [
        :waiting_recruit_decision,
        :hiring_decision,
        :completed_coordination,
        :cancel_coordination
      ],
      default: :waiting_recruit_decision

    field :recruiter_user_name, :string, virtual: true
    field :recruiter_user_icon, :string, virtual: true
    field :candidates_user_name, :string, virtual: true
    field :candidates_user_icon, :string, virtual: true

    belongs_to :candidates_user, User
    belongs_to :recruiter_user, User
    belongs_to :requestor_user, User

    has_many :coordination_members, CoordinationMember,
      on_replace: :delete,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(coordination, attrs) do
    coordination
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
    |> cast_assoc(:coordination_members,
      with: &CoordinationMember.changeset/2
    )
    |> validate_required([:skill_params, :status, :candidates_user_id, :recruiter_user_id])
    |> validate_length(:skill_panel_name, max: 255)
    |> validate_length(:comment, max: 255)
  end
end
