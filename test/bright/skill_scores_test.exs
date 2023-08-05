defmodule Bright.SkillScoresTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.SkillScores

  describe "skill_class_scores" do
    alias Bright.SkillScores.SkillClassScore

    @invalid_attrs %{level: :invalid}

    setup do
      user = insert(:user)
      skill_class = insert(:skill_class, skill_panel: build(:skill_panel))

      %{user: user, skill_class: skill_class}
    end

    test "list_skill_class_scores/0 returns all skill_class_scores", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:skill_class_score, user: user, skill_class: skill_class)

      assert SkillScores.list_skill_class_scores()
             |> Enum.map(& &1.id) == [skill_class_score.id]
    end

    test "get_skill_class_score!/1 returns the skill_class_score with given id", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:skill_class_score, user: user, skill_class: skill_class)
      assert skill_class_score.id == SkillScores.get_skill_class_score!(skill_class_score.id).id
    end

    test "create_skill_class_score/2 creates a skill_class_score and skill_scores", %{
      user: user,
      skill_class: skill_class
    } do
      skill_unit =
        insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 1}])

      [%{skills: [skill_1]}] = insert_skill_categories_and_skills(skill_unit, [1])

      {:ok, %{skill_class_score: skill_class_score, skill_scores: {1, _}}} =
        SkillScores.create_skill_class_score(user, skill_class)

      [skill_score] = Bright.Repo.preload(skill_class_score, :skill_scores).skill_scores
      assert skill_class_score.level == :beginner
      assert skill_score.skill_class_score_id == skill_class_score.id
      assert skill_score.skill_id == skill_1.id
    end

    test "update_skill_class_score/2 with valid data updates the skill_class_score", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:skill_class_score, user: user, skill_class: skill_class)
      update_attrs = %{level: :normal}

      assert {:ok, %SkillClassScore{} = skill_class_score} =
               SkillScores.update_skill_class_score(skill_class_score, update_attrs)

      assert skill_class_score.level == :normal
    end

    test "update_skill_class_score/2 with invalid data returns error changeset", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:skill_class_score, user: user, skill_class: skill_class)

      assert {:error, %Ecto.Changeset{}} =
               SkillScores.update_skill_class_score(skill_class_score, @invalid_attrs)

      assert skill_class_score.level ==
               SkillScores.get_skill_class_score!(skill_class_score.id).level
    end

    test "update_skill_class_score_stats", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:skill_class_score, user: user, skill_class: skill_class)
      skill_unit = insert(:skill_unit, skill_classes: [skill_class])
      [%{skills: [skill_1, skill_2]}] = insert_skill_categories_and_skills(skill_unit, [2])
      insert(:skill_score, skill_class_score: skill_class_score, skill: skill_1, score: :low)
      insert(:skill_score, skill_class_score: skill_class_score, skill: skill_2, score: :high)
      {:ok, skill_class_score} = SkillScores.update_skill_class_score_stats(skill_class_score)

      assert skill_class_score.level == :normal
      assert skill_class_score.percentage == 50.0
    end

    test "update_skill_class_score_stats without items ", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:skill_class_score, user: user, skill_class: skill_class)
      {:ok, skill_class_score} = SkillScores.update_skill_class_score_stats(skill_class_score)

      assert skill_class_score.level == :beginner
      assert skill_class_score.percentage == 0.0
    end

    test "get_level" do
      [
        {0.0, :beginner},
        {39.9, :beginner},
        {40.0, :normal},
        {59.9, :normal},
        {60.0, :skilled},
        {100.0, :skilled}
      ]
      |> Enum.each(fn {percentage, expected_level} ->
        assert expected_level == SkillScores.get_level(percentage)
      end)
    end

    test "delete_skill_class_score/1 deletes the skill_class_score", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:skill_class_score, user: user, skill_class: skill_class)
      assert {:ok, %SkillClassScore{}} = SkillScores.delete_skill_class_score(skill_class_score)

      assert_raise Ecto.NoResultsError, fn ->
        SkillScores.get_skill_class_score!(skill_class_score.id)
      end
    end

    test "change_skill_class_score/1 returns a skill_class_score changeset", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:skill_class_score, user: user, skill_class: skill_class)
      assert %Ecto.Changeset{} = SkillScores.change_skill_class_score(skill_class_score)
    end
  end

  describe "skill_scores" do
    alias Bright.SkillScores.SkillScore

    @invalid_attrs %{score: :invalid}

    setup do
      user = insert(:user)
      skill_class = insert(:skill_class, skill_panel: build(:skill_panel))
      skill_class_score = insert(:skill_class_score, user: user, skill_class: skill_class)

      skill_category = insert(:skill_category, skill_unit: build(:skill_unit), position: 1)
      skill = insert(:skill, skill_category: skill_category, position: 1)

      %{skill_class_score: skill_class_score, skill: skill}
    end

    test "list_skill_scores/0 returns all skill_scores", %{
      skill_class_score: skill_class_score,
      skill: skill
    } do
      skill_score = insert(:skill_score, skill_class_score: skill_class_score, skill: skill)

      assert SkillScores.list_skill_scores()
             |> Enum.map(& &1.id) == [skill_score.id]
    end

    test "get_skill_score!/1 returns the skill_score with given id", %{
      skill_class_score: skill_class_score,
      skill: skill
    } do
      skill_score = insert(:skill_score, skill_class_score: skill_class_score, skill: skill)
      assert SkillScores.get_skill_score!(skill_score.id).id == skill_score.id
    end

    test "update_skill_score/2 with valid data updates the skill_score", %{
      skill_class_score: skill_class_score,
      skill: skill
    } do
      skill_score = insert(:skill_score, skill_class_score: skill_class_score, skill: skill)
      update_attrs = %{score: :high}

      assert {:ok, %SkillScore{} = skill_score} =
               SkillScores.update_skill_score(skill_score, update_attrs)

      assert skill_score.score == :high
    end

    test "update_skill_score/2 with invalid data returns error changeset", %{
      skill_class_score: skill_class_score,
      skill: skill
    } do
      skill_score = insert(:skill_score, skill_class_score: skill_class_score, skill: skill)

      assert {:error, %Ecto.Changeset{}} =
               SkillScores.update_skill_score(skill_score, @invalid_attrs)

      assert skill_score.score ==
               SkillScores.get_skill_score!(skill_score.id).score
    end

    test "delete_skill_score/1 deletes the skill_score", %{
      skill_class_score: skill_class_score,
      skill: skill
    } do
      skill_score = insert(:skill_score, skill_class_score: skill_class_score, skill: skill)
      assert {:ok, %SkillScore{}} = SkillScores.delete_skill_score(skill_score)

      assert_raise Ecto.NoResultsError, fn ->
        SkillScores.get_skill_score!(skill_score.id)
      end
    end

    test "change_skill_score/1 returns a skill_score changeset", %{
      skill_class_score: skill_class_score,
      skill: skill
    } do
      skill_score = insert(:skill_score, skill_class_score: skill_class_score, skill: skill)
      assert %Ecto.Changeset{} = SkillScores.change_skill_score(skill_score)
    end
  end
end
