defmodule Bright.SkillExamsTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.SkillExams

  setup do
    skill_category = insert(:skill_category, skill_unit: build(:skill_unit), position: 1)
    skill = insert(:skill, skill_category: skill_category, position: 1)

    %{skill: skill}
  end

  describe "skill_exams" do
    alias Bright.SkillExams.SkillExam

    @invalid_attrs %{skill_id: nil}

    test "list_skill_exams/0 returns all skill_exams", %{skill: skill} do
      skill_exam = insert(:skill_exam, skill: skill)

      assert SkillExams.list_skill_exams()
             |> Enum.map(& &1.id) == [skill_exam.id]
    end

    test "get_skill_exam!/1 returns the skill_exam with given id", %{skill: skill} do
      skill_exam = insert(:skill_exam, skill: skill)
      assert SkillExams.get_skill_exam!(skill_exam.id).id == skill_exam.id
    end

    test "create_skill_exam/1 with valid data creates a skill_exam", %{skill: skill} do
      valid_attrs = %{skill_id: skill.id}

      assert {:ok, %SkillExam{}} = SkillExams.create_skill_exam(valid_attrs)
    end

    test "create_skill_exam/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SkillExams.create_skill_exam(@invalid_attrs)
    end

    test "update_skill_exam/2 with valid data updates the skill_exam", %{skill: skill} do
      skill_exam = insert(:skill_exam, skill: skill)

      skill_category = insert(:skill_category, skill_unit: build(:skill_unit), position: 1)
      skill_2 = insert(:skill, skill_category: skill_category, position: 1)
      update_attrs = %{skill_id: skill_2.id}

      assert {:ok, %SkillExam{}} = SkillExams.update_skill_exam(skill_exam, update_attrs)
    end

    test "update_skill_exam/2 with invalid data returns error changeset", %{skill: skill} do
      skill_exam = insert(:skill_exam, skill: skill)

      assert {:error, %Ecto.Changeset{}} =
               SkillExams.update_skill_exam(skill_exam, @invalid_attrs)

      assert skill_exam.id == SkillExams.get_skill_exam!(skill_exam.id).id
    end

    test "delete_skill_exam/1 deletes the skill_exam", %{skill: skill} do
      skill_exam = insert(:skill_exam, skill: skill)
      assert {:ok, %SkillExam{}} = SkillExams.delete_skill_exam(skill_exam)
      assert_raise Ecto.NoResultsError, fn -> SkillExams.get_skill_exam!(skill_exam.id) end
    end

    test "change_skill_exam/1 returns a skill_exam changeset", %{skill: skill} do
      skill_exam = insert(:skill_exam, skill: skill)
      assert %Ecto.Changeset{} = SkillExams.change_skill_exam(skill_exam)
    end
  end

  describe "skill_exam_results" do
    alias Bright.SkillExams.SkillExamResult

    @invalid_attrs %{progress: :invalid}

    setup %{skill: skill} do
      user = insert(:user)
      skill_exam = insert(:skill_exam, skill: skill)

      valid_attrs = %{
        user_id: user.id,
        skill_id: skill.id,
        skill_exam_id: skill_exam.id,
        progress: :done
      }

      %{valid_attrs: valid_attrs}
    end

    test "list_skill_exam_results/0 returns all skill_exam_results", %{valid_attrs: valid_attrs} do
      skill_exam_result = insert(:skill_exam_result, valid_attrs)

      assert SkillExams.list_skill_exam_results()
             |> Enum.map(& &1.id) == [skill_exam_result.id]
    end

    test "get_skill_exam_result!/1 returns the skill_exam_result with given id", %{
      valid_attrs: valid_attrs
    } do
      skill_exam_result = insert(:skill_exam_result, valid_attrs)
      assert SkillExams.get_skill_exam_result!(skill_exam_result.id).id == skill_exam_result.id
    end

    test "create_skill_exam_result/1 with valid data creates a skill_exam_result", %{
      valid_attrs: valid_attrs
    } do
      assert {:ok, %SkillExamResult{} = skill_exam_result} =
               SkillExams.create_skill_exam_result(valid_attrs)

      assert skill_exam_result.progress == :done
    end

    test "create_skill_exam_result/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SkillExams.create_skill_exam_result(@invalid_attrs)
    end

    test "update_skill_exam_result/2 with valid data updates the skill_exam_result", %{
      valid_attrs: valid_attrs
    } do
      skill_exam_result = insert(:skill_exam_result, valid_attrs)
      update_attrs = %{progress: :wip}

      assert {:ok, %SkillExamResult{} = skill_exam_result} =
               SkillExams.update_skill_exam_result(skill_exam_result, update_attrs)

      assert skill_exam_result.progress == :wip
    end

    test "update_skill_exam_result/2 with invalid data returns error changeset", %{
      valid_attrs: valid_attrs
    } do
      skill_exam_result = insert(:skill_exam_result, valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               SkillExams.update_skill_exam_result(skill_exam_result, @invalid_attrs)

      assert skill_exam_result == SkillExams.get_skill_exam_result!(skill_exam_result.id)
    end

    test "delete_skill_exam_result/1 deletes the skill_exam_result", %{valid_attrs: valid_attrs} do
      skill_exam_result = insert(:skill_exam_result, valid_attrs)
      assert {:ok, %SkillExamResult{}} = SkillExams.delete_skill_exam_result(skill_exam_result)

      assert_raise Ecto.NoResultsError, fn ->
        SkillExams.get_skill_exam_result!(skill_exam_result.id)
      end
    end

    test "change_skill_exam_result/1 returns a skill_exam_result changeset", %{
      valid_attrs: valid_attrs
    } do
      skill_exam_result = insert(:skill_exam_result, valid_attrs)
      assert %Ecto.Changeset{} = SkillExams.change_skill_exam_result(skill_exam_result)
    end
  end
end
