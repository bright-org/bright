defmodule Bright.RecruitmentStockUsersTest do
  use Bright.DataCase

  alias Bright.RecruitmentStockUsers
  import Bright.Factory

  describe "recruitment_stock_users" do
    test "list_recruitment_stock_users/0 returns all recruitment_stock_users" do
      recruitment_stock_user = insert(:recruitment_stock_user)

      pageparam = %{
        page: 1,
        page_size: 1
      }

      assert RecruitmentStockUsers.list_recruitment_stock_users(
               recruitment_stock_user.recruiter_id,
               pageparam
             ) == %Scrivener.Page{
               page_number: 1,
               page_size: 1,
               total_entries: 1,
               total_pages: 1,
               entries: [recruitment_stock_user.user]
             }
    end
  end
end
