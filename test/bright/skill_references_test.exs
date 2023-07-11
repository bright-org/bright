defmodule Bright.SkillReferencesTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.SkillReferences

  describe "skill_references" do
    alias Bright.SkillReferences.SkillReference

    @invalid_attrs %{skill_id: nil}

    setup do
      skill_category = insert(:skill_category, skill_unit: build(:skill_unit), position: 1)
      skill = insert(:skill, skill_category: skill_category, position: 1)

      %{skill: skill}
    end

    test "list_skill_references/0 returns all skill_references", %{skill: skill} do
      skill_reference = insert(:skill_reference, skill: skill)

      assert SkillReferences.list_skill_references()
             |> Enum.map(& &1.id) == [skill_reference.id]
    end

    test "get_skill_reference!/1 returns the skill_reference with given id", %{skill: skill} do
      skill_reference = insert(:skill_reference, skill: skill)
      assert SkillReferences.get_skill_reference!(skill_reference.id).id == skill_reference.id
    end

    test "create_skill_reference/1 with valid data creates a skill_reference", %{skill: skill} do
      valid_attrs = %{skill_id: skill.id}

      assert {:ok, %SkillReference{}} = SkillReferences.create_skill_reference(valid_attrs)
    end

    test "create_skill_reference/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SkillReferences.create_skill_reference(@invalid_attrs)
    end

    test "update_skill_reference/2 with valid data updates the skill_reference", %{skill: skill} do
      skill_reference = insert(:skill_reference, skill: skill)

      skill_category = insert(:skill_category, skill_unit: build(:skill_unit), position: 1)
      skill_2 = insert(:skill, skill_category: skill_category, position: 1)
      update_attrs = %{skill_id: skill_2.id}

      assert {:ok, %SkillReference{}} =
               SkillReferences.update_skill_reference(skill_reference, update_attrs)
    end

    test "update_skill_reference/2 with invalid data returns error changeset", %{skill: skill} do
      skill_reference = insert(:skill_reference, skill: skill)

      assert {:error, %Ecto.Changeset{}} =
               SkillReferences.update_skill_reference(skill_reference, @invalid_attrs)

      assert skill_reference.id == SkillReferences.get_skill_reference!(skill_reference.id).id
    end

    test "delete_skill_reference/1 deletes the skill_reference", %{skill: skill} do
      skill_reference = insert(:skill_reference, skill: skill)
      assert {:ok, %SkillReference{}} = SkillReferences.delete_skill_reference(skill_reference)

      assert_raise Ecto.NoResultsError, fn ->
        SkillReferences.get_skill_reference!(skill_reference.id)
      end
    end

    test "change_skill_reference/1 returns a skill_reference changeset", %{skill: skill} do
      skill_reference = insert(:skill_reference, skill: skill)
      assert %Ecto.Changeset{} = SkillReferences.change_skill_reference(skill_reference)
    end
  end
end
