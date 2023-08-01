defmodule Bright.SkillPanelsTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.SkillPanels

  describe "skill_panels" do
    alias Bright.SkillPanels.SkillPanel

    @invalid_attrs params_for(:skill_panel) |> Map.put(:name, nil)

    test "list_skill_panels/0 returns all skill_panels" do
      skill_panel = insert(:skill_panel)
      assert SkillPanels.list_skill_panels() == [skill_panel]
    end

    test "get_skill_panel!/1 returns the skill_panel with given id" do
      skill_panel = insert(:skill_panel)
      assert SkillPanels.get_skill_panel!(skill_panel.id) == skill_panel
    end

    test "create_skill_panel/1 with valid data creates a skill_panel" do
      valid_attrs = params_for(:skill_panel)

      assert {:ok, %SkillPanel{} = skill_panel} = SkillPanels.create_skill_panel(valid_attrs)
      assert skill_panel.name == valid_attrs.name
    end

    test "create_skill_panel/1 with skill_classes" do
      valid_attrs =
        params_for(:skill_panel)
        |> Map.put(:skill_classes, [
          params_for(:skill_class, class: nil),
          params_for(:skill_class, class: nil)
        ])

      {:ok, %SkillPanel{} = skill_panel} = SkillPanels.create_skill_panel(valid_attrs)

      [skill_class_1, skill_class_2] = skill_panel.skill_classes
      [valid_attrs_1, valid_attrs_2] = valid_attrs.skill_classes

      assert skill_class_1.name == valid_attrs_1.name
      assert skill_class_1.class == 1
      assert skill_class_2.name == valid_attrs_2.name
      assert skill_class_2.class == 2
    end

    test "create_skill_panel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SkillPanels.create_skill_panel(@invalid_attrs)
    end

    test "update_skill_panel/2 with valid data updates the skill_panel" do
      skill_panel = insert(:skill_panel)
      update_attrs = params_for(:skill_panel)

      assert {:ok, %SkillPanel{} = skill_panel} =
               SkillPanels.update_skill_panel(skill_panel, update_attrs)

      assert skill_panel.name == update_attrs.name
    end

    test "update_skill_panel/2 with invalid data returns error changeset" do
      skill_panel = insert(:skill_panel)

      assert {:error, %Ecto.Changeset{}} =
               SkillPanels.update_skill_panel(skill_panel, @invalid_attrs)

      assert skill_panel == SkillPanels.get_skill_panel!(skill_panel.id)
    end

    test "delete_skill_panel/1 deletes the skill_panel with skill_classes" do
      skill_panel = insert(:skill_panel)
      insert_pair(:skill_class, skill_panel: skill_panel)

      assert {:ok, %{skill_panel: %SkillPanel{}, skill_classes: {2, _}}} =
               SkillPanels.delete_skill_panel(skill_panel)

      assert_raise Ecto.NoResultsError, fn -> SkillPanels.get_skill_panel!(skill_panel.id) end
    end

    test "change_skill_panel/1 returns a skill_panel changeset" do
      skill_panel = insert(:skill_panel)
      assert %Ecto.Changeset{} = SkillPanels.change_skill_panel(skill_panel)
    end
  end

  describe "skill_classes" do
    test "list_skill_classs/0 returns all skill_classs" do
      skill_class = insert(:skill_class, skill_panel: build(:skill_panel))

      assert SkillPanels.list_skill_classes()
             |> Bright.Repo.preload(:skill_panel) == [skill_class]
    end
  end
end
