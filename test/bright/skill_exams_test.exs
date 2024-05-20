defmodule Bright.SkillExamsTest do
  use Bright.DataCase

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

    test "get_skill_exam_by!/1 returns the skill_exam with given condition", %{
      skill: skill
    } do
      skill_exam = insert(:skill_exam, skill: skill)

      assert SkillExams.get_skill_exam_by!(id: skill_exam.id).id == skill_exam.id

      assert_raise Ecto.NoResultsError, fn ->
        SkillExams.get_skill_exam_by!(id: Ecto.ULID.generate())
      end
    end

    test "create_skill_exam/1 with valid data creates a skill_exam", %{skill: skill} do
      valid_attrs = params_for(:skill_exam, skill_id: skill.id)

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

  describe "calc_touch_percentage/2" do
    test "returns percentage floored" do
      assert 33 == SkillExams.calc_touch_percentage(1, 3)
      assert 66 == SkillExams.calc_touch_percentage(2, 3)
    end

    test "returns 0 if size is 0" do
      assert 0 == SkillExams.calc_touch_percentage(0, 0)
      assert 0 == SkillExams.calc_touch_percentage(1, 0)
    end
  end
end
