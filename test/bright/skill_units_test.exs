defmodule Bright.SkillUnitsTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.SkillUnits

  describe "skill_units" do
    alias Bright.SkillUnits.SkillUnit

    @invalid_attrs params_for(:skill_unit) |> Map.put(:name, nil)

    test "list_skill_units/0 returns all skill_units" do
      skill_unit = insert(:skill_unit)
      assert SkillUnits.list_skill_units() == [skill_unit]
    end

    test "get_skill_unit!/1 returns the skill_unit with given id" do
      skill_unit = insert(:skill_unit)
      assert SkillUnits.get_skill_unit!(skill_unit.id) == skill_unit
    end

    test "create_skill_unit/1 with valid data creates a skill_unit" do
      valid_attrs = params_for(:skill_unit)

      assert {:ok, %SkillUnit{} = skill_unit} = SkillUnits.create_skill_unit(valid_attrs)
      assert skill_unit.name == valid_attrs.name
    end

    test "create_skill_unit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SkillUnits.create_skill_unit(@invalid_attrs)
    end

    test "update_skill_unit/2 with valid data updates the skill_unit" do
      skill_unit = insert(:skill_unit)
      update_attrs = params_for(:skill_unit)

      assert {:ok, %SkillUnit{} = skill_unit} =
               SkillUnits.update_skill_unit(skill_unit, update_attrs)

      assert skill_unit.name == update_attrs.name
    end

    test "update_skill_unit/2 with invalid data returns error changeset" do
      skill_unit = insert(:skill_unit)

      assert {:error, %Ecto.Changeset{}} =
               SkillUnits.update_skill_unit(skill_unit, @invalid_attrs)

      assert skill_unit == SkillUnits.get_skill_unit!(skill_unit.id)
    end

    test "delete_skill_unit/1 deletes the skill_unit" do
      skill_unit = insert(:skill_unit)
      assert {:ok, %SkillUnit{}} = SkillUnits.delete_skill_unit(skill_unit)
      assert_raise Ecto.NoResultsError, fn -> SkillUnits.get_skill_unit!(skill_unit.id) end
    end

    test "change_skill_unit/1 returns a skill_unit changeset" do
      skill_unit = insert(:skill_unit)
      assert %Ecto.Changeset{} = SkillUnits.change_skill_unit(skill_unit)
    end
  end

  describe "skill_categories" do
    alias Bright.SkillUnits.SkillCategory

    @invalid_attrs params_for(:skill_category) |> Map.put(:name, nil)

    test "get_skill_category!/1 returns the skill_category with given id" do
      skill_category = insert(:skill_category, skill_unit_id: insert(:skill_unit).id)
      assert SkillUnits.get_skill_category!(skill_category.id) == skill_category
    end

    test "update_skill_category/2 with valid data updates the skill_category" do
      skill_category = insert(:skill_category, skill_unit_id: insert(:skill_unit).id)
      update_attrs = params_for(:skill_category)

      assert {:ok, %SkillCategory{} = skill_category} =
               SkillUnits.update_skill_category(skill_category, update_attrs)

      assert skill_category.name == update_attrs.name
    end

    test "update_skill_category/2 with invalid data returns error changeset" do
      skill_category = insert(:skill_category, skill_unit_id: insert(:skill_unit).id)

      assert {:error, %Ecto.Changeset{}} =
               SkillUnits.update_skill_category(skill_category, @invalid_attrs)

      assert skill_category == SkillUnits.get_skill_category!(skill_category.id)
    end

    test "change_skill_category/1 returns a skill_category changeset" do
      skill_category = insert(:skill_category, skill_unit_id: insert(:skill_unit).id)
      assert %Ecto.Changeset{} = SkillUnits.change_skill_category(skill_category)
    end
  end
end
