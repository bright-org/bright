defmodule Bright.RecruitmentStockUsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.RecruitmentStockUsers` context.
  """

  @doc """
  Generate a recruitment_stock_user.
  """
  def recruitment_stock_user_fixture(attrs \\ %{}) do
    {:ok, recruitment_stock_user} =
      attrs
      |> Enum.into(%{
        recruiter_id: "7488a646-e31f-11e4-aace-600308960662",
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Bright.RecruitmentStockUsers.create_recruitment_stock_user()

    recruitment_stock_user
  end
end
