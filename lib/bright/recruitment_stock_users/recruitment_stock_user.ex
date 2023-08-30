defmodule Bright.RecruitmentStockUsers.RecruitmentStockUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recruitment_stock_users" do
    field :recruiter_id, Ecto.UUID
    field :user_id, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(recruitment_stock_user, attrs) do
    recruitment_stock_user
    |> cast(attrs, [:recruiter_id, :user_id])
    |> validate_required([:recruiter_id, :user_id])
  end
end
