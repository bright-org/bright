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

  describe "skill_classes" do
    alias Bright.SkillPanels.SkillClass

    import Bright.SkillPanelsFixtures

    @invalid_attrs %{name: nil}

    test "list_skill_classes/0 returns all skill_classes" do
      skill_class = skill_class_fixture()
      assert SkillPanels.list_skill_classes() == [skill_class]
    end

    test "get_skill_class!/1 returns the skill_class with given id" do
      skill_class = skill_class_fixture()
      assert SkillPanels.get_skill_class!(skill_class.id) == skill_class
    end

    test "create_skill_class/1 with valid data creates a skill_class" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %SkillClass{} = skill_class} = SkillPanels.create_skill_class(valid_attrs)
      assert skill_class.name == "some name"
    end

    test "create_skill_class/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SkillPanels.create_skill_class(@invalid_attrs)
    end

    test "update_skill_class/2 with valid data updates the skill_class" do
      skill_class = skill_class_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %SkillClass{} = skill_class} =
               SkillPanels.update_skill_class(skill_class, update_attrs)

      assert skill_class.name == "some updated name"
    end

    test "update_skill_class/2 with invalid data returns error changeset" do
      skill_class = skill_class_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SkillPanels.update_skill_class(skill_class, @invalid_attrs)

      assert skill_class == SkillPanels.get_skill_class!(skill_class.id)
    end

    test "delete_skill_class/1 deletes the skill_class" do
      skill_class = skill_class_fixture()
      assert {:ok, %SkillClass{}} = SkillPanels.delete_skill_class(skill_class)
      assert_raise Ecto.NoResultsError, fn -> SkillPanels.get_skill_class!(skill_class.id) end
    end

    test "change_skill_class/1 returns a skill_class changeset" do
      skill_class = skill_class_fixture()
      assert %Ecto.Changeset{} = SkillPanels.change_skill_class(skill_class)
    end
  end
end
