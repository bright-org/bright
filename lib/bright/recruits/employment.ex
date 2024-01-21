defmodule Bright.Recruits.Employment do
  @moduledoc """
  採用調整

  採用検討の選考結果の準備から作成可能
  採用調整画面から一覧できる
  採用候補者からの採用受諾が届いたらチームジョイン先調整が可能になる
  チームジョイン先調整からチームジョインフェーズに進む
  """

  use Ecto.Schema
  alias Bright.Accounts.User
  alias Bright.Recruits.TeamJoinRequest
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "employments" do
    field :message, :string
    field :comment, :string, virtual: true
    field :skill_panel_name, :string
    field :income, :integer
    field :desired_income, :integer
    field :skill_params, :string

    field :status, Ecto.Enum,
      values: [
        :waiting_response,
        :cancel_recruiter,
        :cancel_candidates,
        :acceptance_emplyoment,
        :requested
      ],
      default: :waiting_response

    field :employment_status, Ecto.Enum,
      values: [
        :employee,
        :subcontracting,
        :contract_employee,
        :temporary_employee,
        :part_time_job
      ]

    field :used_sample, Ecto.Enum, values: [:none, :adoption, :not_adoption], default: :none

    field :recruiter_reason, :string
    field :candidates_reason, :string

    belongs_to :candidates_user, User
    belongs_to :recruiter_user, User
    has_many :team_join_requests, TeamJoinRequest, on_replace: :delete, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(employment, attrs) do
    employment
    |> cast(attrs, [
      :income,
      :message,
      :status,
      :employment_status,
      :skill_params,
      :skill_panel_name,
      :used_sample,
      :recruiter_reason,
      :candidates_reason,
      :recruiter_user_id,
      :candidates_user_id
    ])
    |> cast_assoc(:team_join_requests,
      with: &TeamJoinRequest.changeset/2
    )
    |> validate_required([
      :income,
      :message,
      :status,
      :employment_status,
      :recruiter_user_id,
      :candidates_user_id
    ])
  end

  @doc false
  def cancel_changeset(employment, attrs) do
    employment
    |> cast(attrs, [
      :income,
      :message,
      :status,
      :used_sample,
      :recruiter_reason,
      :recruiter_user_id,
      :candidates_user_id
    ])
    |> validate_required([:message, :status, :recruiter_user_id, :candidates_user_id])
  end
end
