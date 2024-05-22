defmodule Bright.RecruitmentStockUsers.RecruitmentStockUser do
  @moduledoc """
  The RecruitmentStockUser context.
  """
  use Ecto.Schema
  alias Bright.Accounts.User
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "recruitment_stock_users" do
    field :skill_panel, :string
    field :desired_income, :decimal
    belongs_to :recruiter, User
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(recruitment_stock_user, attrs) do
    recruitment_stock_user
    |> cast(attrs, [:recruiter_id, :user_id, :skill_panel, :desired_income])
    |> validate_required([:recruiter_id, :user_id, :skill_panel])
  end
end
