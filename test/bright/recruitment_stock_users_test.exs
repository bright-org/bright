defmodule Bright.RecruitmentStockUsersTest do
  use Bright.DataCase

  alias Bright.RecruitmentStockUsers

  describe "recruitment_stock_users" do
    alias Bright.RecruitmentStockUsers.RecruitmentStockUser

    import Bright.RecruitmentStockUsersFixtures

    @invalid_attrs %{recruiter_id: nil, user_id: nil}

    test "list_recruitment_stock_users/0 returns all recruitment_stock_users" do
      recruitment_stock_user = recruitment_stock_user_fixture()
      assert RecruitmentStockUsers.list_recruitment_stock_users() == [recruitment_stock_user]
    end

    test "get_recruitment_stock_user!/1 returns the recruitment_stock_user with given id" do
      recruitment_stock_user = recruitment_stock_user_fixture()
      assert RecruitmentStockUsers.get_recruitment_stock_user!(recruitment_stock_user.id) == recruitment_stock_user
    end

    test "create_recruitment_stock_user/1 with valid data creates a recruitment_stock_user" do
      valid_attrs = %{recruiter_id: "7488a646-e31f-11e4-aace-600308960662", user_id: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %RecruitmentStockUser{} = recruitment_stock_user} = RecruitmentStockUsers.create_recruitment_stock_user(valid_attrs)
      assert recruitment_stock_user.recruiter_id == "7488a646-e31f-11e4-aace-600308960662"
      assert recruitment_stock_user.user_id == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_recruitment_stock_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = RecruitmentStockUsers.create_recruitment_stock_user(@invalid_attrs)
    end

    test "update_recruitment_stock_user/2 with valid data updates the recruitment_stock_user" do
      recruitment_stock_user = recruitment_stock_user_fixture()
      update_attrs = %{recruiter_id: "7488a646-e31f-11e4-aace-600308960668", user_id: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %RecruitmentStockUser{} = recruitment_stock_user} = RecruitmentStockUsers.update_recruitment_stock_user(recruitment_stock_user, update_attrs)
      assert recruitment_stock_user.recruiter_id == "7488a646-e31f-11e4-aace-600308960668"
      assert recruitment_stock_user.user_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_recruitment_stock_user/2 with invalid data returns error changeset" do
      recruitment_stock_user = recruitment_stock_user_fixture()
      assert {:error, %Ecto.Changeset{}} = RecruitmentStockUsers.update_recruitment_stock_user(recruitment_stock_user, @invalid_attrs)
      assert recruitment_stock_user == RecruitmentStockUsers.get_recruitment_stock_user!(recruitment_stock_user.id)
    end

    test "delete_recruitment_stock_user/1 deletes the recruitment_stock_user" do
      recruitment_stock_user = recruitment_stock_user_fixture()
      assert {:ok, %RecruitmentStockUser{}} = RecruitmentStockUsers.delete_recruitment_stock_user(recruitment_stock_user)
      assert_raise Ecto.NoResultsError, fn -> RecruitmentStockUsers.get_recruitment_stock_user!(recruitment_stock_user.id) end
    end

    test "change_recruitment_stock_user/1 returns a recruitment_stock_user changeset" do
      recruitment_stock_user = recruitment_stock_user_fixture()
      assert %Ecto.Changeset{} = RecruitmentStockUsers.change_recruitment_stock_user(recruitment_stock_user)
    end
  end
end
