defmodule Bright.RecruitmentStockUsers.RecruitmentStockUser do
  @moduledoc """
  The RecruitmentStockUser context.
  """
  use Ecto.Schema

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  alias Bright.Accounts.User

  schema "recruitment_stock_users" do
    belongs_to :recruiter, User
    belongs_to :user, User

    timestamps()
  end
end
