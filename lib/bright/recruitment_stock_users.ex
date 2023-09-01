defmodule Bright.RecruitmentStockUsers do
  @moduledoc """
  The RecruitmentStockUsers context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.RecruitmentStockUsers.RecruitmentStockUser

  @doc """
  Returns the list of recruitment_stock_users.

  ## Examples

      iex> list_recruitment_stock_users(recruiter_id, %{page: 1, page_size: 10})
      [%RecruitmentStockUser{}, ...]

  """
  def list_recruitment_stock_users(recruiter_id, page_param) do
    from(recruitment_stock_users in RecruitmentStockUser,
      join: user in assoc(recruitment_stock_users, :user),
      where: recruitment_stock_users.recruiter_id == ^recruiter_id,
      order_by: [asc: recruitment_stock_users.inserted_at],
      select: user
    )
    |> Repo.paginate(page_param)
  end
end
