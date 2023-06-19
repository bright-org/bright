defmodule Bright.SkillPanelsTest do
  use Bright.DataCase

  alias Bright.SkillPanels

  describe "skill_panels" do
    alias Bright.SkillPanels.SkillPanel

    import Bright.SkillPanelsFixtures

    @invalid_attrs %{name: nil, locked_date: nil}

    test "list_skill_panels/0 returns all skill_panels" do
      skill_panel = skill_panel_fixture()
      assert SkillPanels.list_skill_panels() == [skill_panel]
    end

    test "get_skill_panel!/1 returns the skill_panel with given id" do
      skill_panel = skill_panel_fixture()
      assert SkillPanels.get_skill_panel!(skill_panel.id) == skill_panel
    end

    test "create_skill_panel/1 with valid data creates a skill_panel" do
      valid_attrs = %{name: "some name", locked_date: ~D[2023-06-15]}

      assert {:ok, %SkillPanel{} = skill_panel} = SkillPanels.create_skill_panel(valid_attrs)
      assert skill_panel.name == "some name"
      assert skill_panel.locked_date == ~D[2023-06-15]
    end

    test "create_skill_panel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SkillPanels.create_skill_panel(@invalid_attrs)
    end

    test "update_skill_panel/2 with valid data updates the skill_panel" do
      skill_panel = skill_panel_fixture()
      update_attrs = %{name: "some updated name", locked_date: ~D[2023-06-16]}

      assert {:ok, %SkillPanel{} = skill_panel} =
               SkillPanels.update_skill_panel(skill_panel, update_attrs)

      assert skill_panel.name == "some updated name"
      assert skill_panel.locked_date == ~D[2023-06-16]
    end

    test "update_skill_panel/2 with invalid data returns error changeset" do
      skill_panel = skill_panel_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SkillPanels.update_skill_panel(skill_panel, @invalid_attrs)

      assert skill_panel == SkillPanels.get_skill_panel!(skill_panel.id)
    end

    test "delete_skill_panel/1 deletes the skill_panel" do
      skill_panel = skill_panel_fixture()
      assert {:ok, %SkillPanel{}} = SkillPanels.delete_skill_panel(skill_panel)
      assert_raise Ecto.NoResultsError, fn -> SkillPanels.get_skill_panel!(skill_panel.id) end
    end

    test "change_skill_panel/1 returns a skill_panel changeset" do
      skill_panel = skill_panel_fixture()
      assert %Ecto.Changeset{} = SkillPanels.change_skill_panel(skill_panel)
    end
  end
end
