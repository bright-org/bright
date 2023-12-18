defmodule Bright.Recruits.Employment do
  use Ecto.Schema
  alias Bright.Accounts.User
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "employments" do
    field :message, :string
    field :skill_panel_name, :string
    field :income, :integer
    field :desired_income, :integer
    field :skill_params, :string
    field :status, Ecto.Enum,
      values: [:waiting_response, :cancel_recruiter, :cancel_candidates, :acceptance_emplyoment],
      default: :waiting_response

    field :recruiter_reason, :string
    field :candidates_reason, :string

    belongs_to :candidates_user, User
    belongs_to :recruiter_user, User

    timestamps()
  end

  @doc false
  def changeset(employment, attrs) do
    employment
    |> cast(attrs, [
      :income,
      :message,
      :status,
      :recruiter_reason,
      :candidates_reason,
      :recruiter_user_id,
      :candidates_user_id
    ])
    |> validate_required([:income, :message, :status, :recruiter_user_id, :candidates_user_id])
  end
end
