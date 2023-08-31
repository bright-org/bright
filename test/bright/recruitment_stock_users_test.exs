defmodule Bright.RecruitmentStockUsersTest do
  use Bright.DataCase

  alias Bright.RecruitmentStockUsers
  import Bright.Factory

  describe "recruitment_stock_users" do
    test "list_recruitment_stock_users/0 returns all recruitment_stock_users" do
      recruitment_stock_user = insert(:recruitment_stock_user)

      assert RecruitmentStockUsers.list_recruitment_stock_users(
               recruitment_stock_user.recruiter_id
             ) == [recruitment_stock_user.user_id]
    end
  end
end
