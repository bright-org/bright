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

      iex> list_recruitment_stock_users()
      [%RecruitmentStockUser{}, ...]

  """
  def list_recruitment_stock_users do
    Repo.all(RecruitmentStockUser)
  end
end
