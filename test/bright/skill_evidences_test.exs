defmodule Bright.SkillEvidencesTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.SkillEvidences

  describe "skill_evidences" do
    alias Bright.SkillEvidences.SkillEvidence

    @invalid_attrs %{progress: :invalid}

    setup do
      user = insert(:user)
      skill_category = insert(:skill_category, skill_unit: build(:skill_unit), position: 1)
      skill = insert(:skill, skill_category: skill_category, position: 1)

      valid_attrs = %{
        user_id: user.id,
        skill_id: skill.id,
        progress: :done
      }

      %{valid_attrs: valid_attrs}
    end

    test "list_skill_evidences/0 returns all skill_evidences", %{valid_attrs: valid_attrs} do
      skill_evidence = insert(:skill_evidence, valid_attrs)
      assert SkillEvidences.list_skill_evidences() == [skill_evidence]
    end

    test "get_skill_evidence!/1 returns the skill_evidence with given id", %{
      valid_attrs: valid_attrs
    } do
      skill_evidence = insert(:skill_evidence, valid_attrs)
      assert SkillEvidences.get_skill_evidence!(skill_evidence.id) == skill_evidence
    end

    test "create_skill_evidence/1 with valid data creates a skill_evidence", %{
      valid_attrs: valid_attrs
    } do
      assert {:ok, %SkillEvidence{} = skill_evidence} =
               SkillEvidences.create_skill_evidence(valid_attrs)

      assert skill_evidence.progress == :done
    end

    test "create_skill_evidence/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SkillEvidences.create_skill_evidence(@invalid_attrs)
    end

    test "update_skill_evidence/2 with valid data updates the skill_evidence", %{
      valid_attrs: valid_attrs
    } do
      skill_evidence = insert(:skill_evidence, valid_attrs)
      update_attrs = %{progress: :wip}

      assert {:ok, %SkillEvidence{} = skill_evidence} =
               SkillEvidences.update_skill_evidence(skill_evidence, update_attrs)

      assert skill_evidence.progress == :wip
    end

    test "update_skill_evidence/2 with invalid data returns error changeset", %{
      valid_attrs: valid_attrs
    } do
      skill_evidence = insert(:skill_evidence, valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               SkillEvidences.update_skill_evidence(skill_evidence, @invalid_attrs)

      assert skill_evidence == SkillEvidences.get_skill_evidence!(skill_evidence.id)
    end

    test "delete_skill_evidence/1 deletes the skill_evidence", %{valid_attrs: valid_attrs} do
      skill_evidence = insert(:skill_evidence, valid_attrs)
      assert {:ok, %SkillEvidence{}} = SkillEvidences.delete_skill_evidence(skill_evidence)

      assert_raise Ecto.NoResultsError, fn ->
        SkillEvidences.get_skill_evidence!(skill_evidence.id)
      end
    end

    test "change_skill_evidence/1 returns a skill_evidence changeset", %{valid_attrs: valid_attrs} do
      skill_evidence = insert(:skill_evidence, valid_attrs)
      assert %Ecto.Changeset{} = SkillEvidences.change_skill_evidence(skill_evidence)
    end
  end
end
