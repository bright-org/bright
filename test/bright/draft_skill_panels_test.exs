defmodule Bright.DraftSkillPanelsTest do
  use Bright.DataCase

  alias Bright.DraftSkillPanels

  describe "skill_panels" do
    alias Bright.DraftSkillPanels.SkillPanel

    @invalid_attrs params_for(:draft_skill_panel) |> Map.put(:name, nil)

    test "list_skill_panels/0 returns all skill_panels" do
      skill_panel = insert(:draft_skill_panel)
      assert DraftSkillPanels.list_skill_panels() == [skill_panel]
    end

    test "get_skill_panel!/1 returns the skill_panel with given id" do
      skill_panel = insert(:draft_skill_panel)
      assert DraftSkillPanels.get_skill_panel!(skill_panel.id) == skill_panel
    end

    test "create_skill_panel/1 with valid data creates a skill_panel" do
      valid_attrs = params_for(:draft_skill_panel)

      assert {:ok, %SkillPanel{} = skill_panel} = DraftSkillPanels.create_skill_panel(valid_attrs)
      assert skill_panel.name == valid_attrs.name
    end

    test "create_skill_panel/1 with draft_skill_classes" do
      valid_attrs =
        params_for(:draft_skill_panel)
        |> Map.put(:draft_skill_classes, [
          params_for(:draft_skill_class, class: nil),
          params_for(:draft_skill_class, class: nil)
        ])

      {:ok, %SkillPanel{} = skill_panel} = DraftSkillPanels.create_skill_panel(valid_attrs)

      [draft_skill_class_1, draft_skill_class_2] = skill_panel.draft_skill_classes
      [valid_attrs_1, valid_attrs_2] = valid_attrs.draft_skill_classes

      assert draft_skill_class_1.name == valid_attrs_1.name
      assert draft_skill_class_1.class == 1
      assert draft_skill_class_2.name == valid_attrs_2.name
      assert draft_skill_class_2.class == 2
    end

    test "create_skill_panel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DraftSkillPanels.create_skill_panel(@invalid_attrs)
    end

    test "update_skill_panel/2 with valid data updates the skill_panel" do
      skill_panel = insert(:draft_skill_panel)
      update_attrs = params_for(:draft_skill_panel)

      assert {:ok, %SkillPanel{} = skill_panel} =
               DraftSkillPanels.update_skill_panel(skill_panel, update_attrs)

      assert skill_panel.name == update_attrs.name
    end

    test "update_skill_panel/2 with invalid data returns error changeset" do
      skill_panel = insert(:draft_skill_panel)

      assert {:error, %Ecto.Changeset{}} =
               DraftSkillPanels.update_skill_panel(skill_panel, @invalid_attrs)

      assert skill_panel == DraftSkillPanels.get_skill_panel!(skill_panel.id)
    end

    test "delete_skill_panel/1 deletes the skill_panel with skill_classes" do
      skill_panel = insert(:draft_skill_panel)
      insert_pair(:draft_skill_class, skill_panel: skill_panel)

      assert {:ok, %{skill_panel: %SkillPanel{}, draft_skill_classes: {2, _}}} =
               DraftSkillPanels.delete_skill_panel(skill_panel)

      assert_raise Ecto.NoResultsError, fn ->
        DraftSkillPanels.get_skill_panel!(skill_panel.id)
      end
    end

    test "change_skill_panel/1 returns a skill_panel changeset" do
      skill_panel = insert(:draft_skill_panel)
      assert %Ecto.Changeset{} = DraftSkillPanels.change_skill_panel(skill_panel)
    end
  end

  describe "draft_skill_classes" do
    test "list_draft_skill_classes/0 returns all draft_skill_classes" do
      draft_skill_class = insert(:draft_skill_class, skill_panel: build(:draft_skill_panel))

      assert DraftSkillPanels.list_draft_skill_classes()
             |> Bright.Repo.preload(:skill_panel) == [draft_skill_class]
    end
  end
end
