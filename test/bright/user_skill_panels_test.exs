defmodule Bright.UserSkillPanelsTest do
  use Bright.DataCase

  alias Bright.Repo
  alias Bright.UserSkillPanels
  import Bright.Factory

  describe "user_skill_panels" do
    alias Bright.UserSkillPanels.UserSkillPanel

    @invalid_attrs %{user_id: nil, skill_panel_id: nil}

    test "list_user_skill_panels/0 returns all user_skill_panels" do
      %{id: id} = insert(:user_skill_panel)

      assert [%{id: ^id}] = UserSkillPanels.list_user_skill_panels()
    end

    test "get_user_skill_panel!/1 returns the user_skill_panel with given id" do
      user_skill_panel = insert(:user_skill_panel)

      assert user_skill_panel.id
             |> UserSkillPanels.get_user_skill_panel!()
             |> Repo.preload(skill_panel: :career_field) == user_skill_panel
    end

    test "create_user_skill_panel/1 with valid data creates a user_skill_panel" do
      user = insert(:user)
      skill_panel = insert(:skill_panel)
      valid_attrs = %{user_id: user.id, skill_panel_id: skill_panel.id}

      assert {:ok, %UserSkillPanel{} = user_skill_panel} =
               UserSkillPanels.create_user_skill_panel(valid_attrs)

      assert user_skill_panel.user_id == user.id
      assert user_skill_panel.skill_panel_id == skill_panel.id
    end

    test "create_user_skill_panel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserSkillPanels.create_user_skill_panel(@invalid_attrs)
    end

    test "update_user_skill_panel/2 with valid data updates the user_skill_panel" do
      user_skill_panel = insert(:user_skill_panel)
      user = insert(:user)
      skill_panel = insert(:skill_panel)
      update_attrs = %{user_id: user.id, skill_panel_id: skill_panel.id}

      assert {:ok, %UserSkillPanel{} = user_skill_panel} =
               UserSkillPanels.update_user_skill_panel(user_skill_panel, update_attrs)

      assert user_skill_panel.user_id == user.id
      assert user_skill_panel.skill_panel_id == skill_panel.id
    end

    test "update_user_skill_panel/2 with invalid data returns error changeset" do
      user_skill_panel = insert(:user_skill_panel)

      assert {:error, %Ecto.Changeset{}} =
               UserSkillPanels.update_user_skill_panel(user_skill_panel, @invalid_attrs)

      assert user_skill_panel ==
               user_skill_panel.id
               |> UserSkillPanels.get_user_skill_panel!()
               |> Repo.preload(skill_panel: :career_field)
    end

    test "delete_user_skill_panel/1 deletes the user_skill_panel" do
      user_skill_panel = insert(:user_skill_panel)
      assert {:ok, %UserSkillPanel{}} = UserSkillPanels.delete_user_skill_panel(user_skill_panel)

      assert_raise Ecto.NoResultsError, fn ->
        UserSkillPanels.get_user_skill_panel!(user_skill_panel.id)
      end
    end

    test "change_user_skill_panel/1 returns a user_skill_panel changeset" do
      user_skill_panel = insert(:user_skill_panel)
      assert %Ecto.Changeset{} = UserSkillPanels.change_user_skill_panel(user_skill_panel)
    end
  end
end
