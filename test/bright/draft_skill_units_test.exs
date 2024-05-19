defmodule Bright.DraftSkillUnitsTest do
  use Bright.DataCase

  alias Bright.DraftSkillUnits

  describe "draft_skill_units" do
    alias Bright.DraftSkillUnits.DraftSkillUnit

    @invalid_attrs params_for(:draft_skill_unit) |> Map.put(:name, nil)

    test "list_draft_skill_units/0 returns all draft_skill_units" do
      draft_skill_unit = insert(:draft_skill_unit)
      assert DraftSkillUnits.list_draft_skill_units() == [draft_skill_unit]
    end

    test "get_draft_skill_unit!/1 returns the draft_skill_unit with given id" do
      draft_skill_unit = insert(:draft_skill_unit)
      assert DraftSkillUnits.get_draft_skill_unit!(draft_skill_unit.id) == draft_skill_unit
    end

    test "create_draft_skill_unit/1 with valid data creates a draft_skill_unit" do
      valid_attrs = params_for(:draft_skill_unit)

      assert {:ok, %DraftSkillUnit{} = draft_skill_unit} =
               DraftSkillUnits.create_draft_skill_unit(valid_attrs)

      assert draft_skill_unit.name == valid_attrs.name
    end

    test "create_draft_skill_unit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DraftSkillUnits.create_draft_skill_unit(@invalid_attrs)
    end

    test "update_draft_skill_unit/2 with valid data updates the draft_skill_unit" do
      draft_skill_unit = insert(:draft_skill_unit)
      update_attrs = params_for(:draft_skill_unit)

      assert {:ok, %DraftSkillUnit{} = draft_skill_unit} =
               DraftSkillUnits.update_draft_skill_unit(draft_skill_unit, update_attrs)

      assert draft_skill_unit.name == update_attrs.name
    end

    test "update_draft_skill_unit/2 with invalid data returns error changeset" do
      draft_skill_unit = insert(:draft_skill_unit)

      assert {:error, %Ecto.Changeset{}} =
               DraftSkillUnits.update_draft_skill_unit(draft_skill_unit, @invalid_attrs)

      assert draft_skill_unit == DraftSkillUnits.get_draft_skill_unit!(draft_skill_unit.id)
    end

    test "delete_draft_skill_unit/1 deletes the draft_skill_unit" do
      draft_skill_unit = insert(:draft_skill_unit)
      assert {:ok, %DraftSkillUnit{}} = DraftSkillUnits.delete_draft_skill_unit(draft_skill_unit)

      assert_raise Ecto.NoResultsError, fn ->
        DraftSkillUnits.get_draft_skill_unit!(draft_skill_unit.id)
      end
    end

    test "change_draft_skill_unit/1 returns a draft_skill_unit changeset" do
      draft_skill_unit = insert(:draft_skill_unit)
      assert %Ecto.Changeset{} = DraftSkillUnits.change_draft_skill_unit(draft_skill_unit)
    end
  end

  describe "draft_skill_categories" do
    alias Bright.DraftSkillUnits.DraftSkillCategory

    @invalid_attrs params_for(:draft_skill_category) |> Map.put(:name, nil)

    test "get_draft_skill_category!/1 returns the draft_skill_category with given id" do
      draft_skill_category =
        insert(:draft_skill_category, draft_skill_unit_id: insert(:draft_skill_unit).id)

      assert DraftSkillUnits.get_draft_skill_category!(draft_skill_category.id) ==
               draft_skill_category
    end

    test "update_draft_skill_category/2 with valid data updates the draft_skill_category" do
      draft_skill_category =
        insert(:draft_skill_category, draft_skill_unit_id: insert(:draft_skill_unit).id)

      update_attrs = params_for(:draft_skill_category)

      assert {:ok, %DraftSkillCategory{} = draft_skill_category} =
               DraftSkillUnits.update_draft_skill_category(draft_skill_category, update_attrs)

      assert draft_skill_category.name == update_attrs.name
    end

    test "update_draft_skill_category/2 with invalid data returns error changeset" do
      draft_skill_category =
        insert(:draft_skill_category, draft_skill_unit_id: insert(:draft_skill_unit).id)

      assert {:error, %Ecto.Changeset{}} =
               DraftSkillUnits.update_draft_skill_category(draft_skill_category, @invalid_attrs)

      assert draft_skill_category ==
               DraftSkillUnits.get_draft_skill_category!(draft_skill_category.id)
    end

    test "change_draft_skill_category/1 returns a draft_skill_category changeset" do
      draft_skill_category =
        insert(:draft_skill_category, draft_skill_unit_id: insert(:draft_skill_unit).id)

      assert %Ecto.Changeset{} = DraftSkillUnits.change_draft_skill_category(draft_skill_category)
    end
  end
end
