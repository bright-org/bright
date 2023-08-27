defmodule Bright.RecruitmentStockUsersTest do
  use Bright.DataCase

  alias Bright.RecruitmentStockUsers
  alias Bright.RecruitmentStockUsers.RecruitmentStockUser
  import Bright.Factory

  @invalid_attrs %{
    recruiter_id: nil,
    user_id: nil,
    desired_income: nil,
    skill_panel: nil
  }
  describe "recruitment_stock_users" do
    test "list_recruitment_stock_users/2 returns user's all recruitment_stock_users" do
      recruitment_stock_user = %{id: id} = insert(:recruitment_stock_user)

      pageparam = %{
        page: 1,
        page_size: 1
      }

      assert %Scrivener.Page{
               page_number: 1,
               page_size: 1,
               total_entries: 1,
               total_pages: 1,
               entries: [%{id: ^id}]
             } =
               RecruitmentStockUsers.list_recruitment_stock_users(
                 recruitment_stock_user.recruiter_id,
                 pageparam
               )
    end

    test "list_recruitment_stock_user_ids/1 returns all recruitment_stock_users" do
      user = %{id: recruiter_id} = insert(:user)
      %{user_id: stock_id} = insert(:recruitment_stock_user, recruiter: user)
      assert [^stock_id] = RecruitmentStockUsers.list_stock_user_ids(recruiter_id)
    end

    test "get_recruitment_stock_user!/1 returns the recruitment_stock_user with given id" do
      %{id: id} = insert(:recruitment_stock_user)
      assert %{id: ^id} = RecruitmentStockUsers.get_recruitment_stock_user!(id)
    end

    test "create_recruitment_stock_user/1 with valid data creates a recruitment_stock_user" do
      recruiter = insert(:user)
      user = insert(:user)

      valid_attrs =
        params_for(:recruitment_stock_user)
        |> Map.merge(%{recruiter_id: recruiter.id, user_id: user.id})

      assert {:ok, %RecruitmentStockUser{} = recruitment_stock_user} =
               RecruitmentStockUsers.create_recruitment_stock_user(valid_attrs)

      assert recruitment_stock_user.skill_panel == "テストスキルパネル"
    end

    test "create_recruitment_stock_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               RecruitmentStockUsers.create_recruitment_stock_user(@invalid_attrs)
    end

    test "update_recruitment_stock_user/2 with valid data updates the recruitment_stock_user" do
      recruitment_stock_user = insert(:recruitment_stock_user)
      update_attrs = %{skill_panel: "Webアプリ開発 Elixir"}

      assert {:ok, %RecruitmentStockUser{} = recruitment_stock_user} =
               RecruitmentStockUsers.update_recruitment_stock_user(
                 recruitment_stock_user,
                 update_attrs
               )

      assert recruitment_stock_user.skill_panel == "Webアプリ開発 Elixir"
    end

    test "update_recruitment_stock_user/2 with invalid data returns error changeset" do
      recruitment_stock_user = insert(:recruitment_stock_user)

      assert {:error, %Ecto.Changeset{}} =
               RecruitmentStockUsers.update_recruitment_stock_user(
                 recruitment_stock_user,
                 @invalid_attrs
               )

      assert recruitment_stock_user.updated_at ==
               RecruitmentStockUsers.get_recruitment_stock_user!(recruitment_stock_user.id).updated_at
    end

    test "delete_recruitment_stock_user/1 deletes the recruitment_stock_user" do
      recruitment_stock_user = insert(:recruitment_stock_user)

      assert {:ok, %RecruitmentStockUser{}} =
               RecruitmentStockUsers.delete_recruitment_stock_user(recruitment_stock_user)

      assert_raise Ecto.NoResultsError, fn ->
        RecruitmentStockUsers.get_recruitment_stock_user!(recruitment_stock_user.id)
      end
    end

    test "change_recruitment_stock_user/1 returns a recruitment_stock_user changeset" do
      recruitment_stock_user = insert(:recruitment_stock_user)

      assert %Ecto.Changeset{} =
               RecruitmentStockUsers.change_recruitment_stock_user(recruitment_stock_user)
    end
  end
end
