defmodule Bright.UserSkillPanelsTest do
  use Bright.DataCase

  alias Bright.UserSkillPanels
  import Bright.Factory

  describe "user_skill_panels" do

    @invalid_attrs %{user_id: nil, skill_panel_id: nil}

    test "list_user_skill_panels/0 returns all user_skill_panels" do
      user_skill_panel = insert(:user_skill_panel)

      assert UserSkillPanels.list_user_skill_panels() == [user_skill_panel]
    end

    # test "get_user_skill_panel!/1 returns the user_skill_panel with given id" do
    #   user_skill_panel = insert(:user_skill_panel)
    #   assert UserSkillPanels.get_user_skill_panel!(user_skill_panel.id) == user_skill_panel
    # end

    # test "create_user_skill_panel/1 with valid data creates a user_skill_panel" do
    #   valid_attrs = %{user_id: "7488a646-e31f-11e4-aace-600308960662", skill_panel_id: "7488a646-e31f-11e4-aace-600308960662"}

    #   assert {:ok, %UserSkillPanel{} = user_skill_panel} = UserSkillPanels.create_user_skill_panel(valid_attrs)
    #   assert user_skill_panel.user_id == "7488a646-e31f-11e4-aace-600308960662"
    #   assert user_skill_panel.skill_panel_id == "7488a646-e31f-11e4-aace-600308960662"
    # end

    # test "create_user_skill_panel/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = UserSkillPanels.create_user_skill_panel(@invalid_attrs)
    # end

    # test "update_user_skill_panel/2 with valid data updates the user_skill_panel" do
    #   user_skill_panel = insert(:user_skill_panel)
    #   update_attrs = %{user_id: "7488a646-e31f-11e4-aace-600308960668", skill_panel_id: "7488a646-e31f-11e4-aace-600308960668"}

    #   assert {:ok, %UserSkillPanel{} = user_skill_panel} = UserSkillPanels.update_user_skill_panel(user_skill_panel, update_attrs)
    #   assert user_skill_panel.user_id == "7488a646-e31f-11e4-aace-600308960668"
    #   assert user_skill_panel.skill_panel_id == "7488a646-e31f-11e4-aace-600308960668"
    # end

    # test "update_user_skill_panel/2 with invalid data returns error changeset" do
    #   user_skill_panel = insert(:user_skill_panel)
    #   assert {:error, %Ecto.Changeset{}} = UserSkillPanels.update_user_skill_panel(user_skill_panel, @invalid_attrs)
    #   assert user_skill_panel == UserSkillPanels.get_user_skill_panel!(user_skill_panel.id)
    # end

    # test "delete_user_skill_panel/1 deletes the user_skill_panel" do
    #   user_skill_panel = insert(:user_skill_panel)
    #   assert {:ok, %UserSkillPanel{}} = UserSkillPanels.delete_user_skill_panel(user_skill_panel)
    #   assert_raise Ecto.NoResultsError, fn -> UserSkillPanels.get_user_skill_panel!(user_skill_panel.id) end
    # end

    # test "change_user_skill_panel/1 returns a user_skill_panel changeset" do
    #    user_skill_panel = insert(:user_skill_panel)
    #   assert %Ecto.Changeset{} = UserSkillPanels.change_user_skill_panel(user_skill_panel)
    # end
  end
end
