defmodule Bright.SkillScoresTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.SkillScores

  describe "skill_scores" do
    alias Bright.SkillScores.SkillScore

    @invalid_attrs %{level: :invalid}

    setup do
      user = insert(:user)
      skill_class = insert(:skill_class, skill_panel: build(:skill_panel))

      %{user: user, skill_class: skill_class}
    end

    test "list_skill_scores/0 returns all skill_scores", %{
      user: user,
      skill_class: skill_class
    } do
      skill_score = insert(:skill_score, user: user, skill_class: skill_class)

      assert SkillScores.list_skill_scores()
             |> Enum.map(& &1.id) == [skill_score.id]
    end

    test "get_skill_score!/1 returns the skill_score with given id", %{
      user: user,
      skill_class: skill_class
    } do
      skill_score = insert(:skill_score, user: user, skill_class: skill_class)
      assert skill_score.id == SkillScores.get_skill_score!(skill_score.id).id
    end

    test "create_skill_score/2 creates a skill_score and skill_score_items", %{
      user: user,
      skill_class: skill_class
    } do
      skill_unit =
        insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 1}])

      [%{skills: [skill_1]}] = insert_skill_categories_and_skills(skill_unit, [1])

      {:ok, %{skill_score: skill_score, skill_score_items: {1, _}}} =
        SkillScores.create_skill_score(user, skill_class)

      [skill_score_item] = Bright.Repo.preload(skill_score, :skill_score_items).skill_score_items
      assert skill_score.level == :beginner
      assert skill_score_item.skill_score_id == skill_score.id
      assert skill_score_item.skill_id == skill_1.id
    end

    test "update_skill_score/2 with valid data updates the skill_score", %{
      user: user,
      skill_class: skill_class
    } do
      skill_score = insert(:skill_score, user: user, skill_class: skill_class)
      update_attrs = %{level: :normal}

      assert {:ok, %SkillScore{} = skill_score} =
               SkillScores.update_skill_score(skill_score, update_attrs)

      assert skill_score.level == :normal
    end

    test "update_skill_score/2 with invalid data returns error changeset", %{
      user: user,
      skill_class: skill_class
    } do
      skill_score = insert(:skill_score, user: user, skill_class: skill_class)

      assert {:error, %Ecto.Changeset{}} =
               SkillScores.update_skill_score(skill_score, @invalid_attrs)

      assert skill_score.level == SkillScores.get_skill_score!(skill_score.id).level
    end

    test "aggregate_skill_score_items", %{
      user: user,
      skill_class: skill_class
    } do
      skill_score = insert(:skill_score, user: user, skill_class: skill_class)
      skill_unit = insert(:skill_unit, skill_classes: [skill_class])
      [%{skills: [skill_1, skill_2]}] = insert_skill_categories_and_skills(skill_unit, [2])
      insert(:skill_score_item, skill_score: skill_score, skill: skill_1, score: :low)
      insert(:skill_score_item, skill_score: skill_score, skill: skill_2, score: :high)
      {:ok, skill_score} = SkillScores.aggregate_skill_score_items(skill_score)

      assert skill_score.level == :normal
      assert skill_score.percentage == 50.0
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

    test "delete_skill_score/1 deletes the skill_score", %{
      user: user,
      skill_class: skill_class
    } do
      skill_score = insert(:skill_score, user: user, skill_class: skill_class)
      assert {:ok, %SkillScore{}} = SkillScores.delete_skill_score(skill_score)
      assert_raise Ecto.NoResultsError, fn -> SkillScores.get_skill_score!(skill_score.id) end
    end

    test "change_skill_score/1 returns a skill_score changeset", %{
      user: user,
      skill_class: skill_class
    } do
      skill_score = insert(:skill_score, user: user, skill_class: skill_class)
      assert %Ecto.Changeset{} = SkillScores.change_skill_score(skill_score)
    end
  end

  describe "skill_score_items" do
    alias Bright.SkillScores.SkillScoreItem

    @invalid_attrs %{score: :invalid}

    setup do
      user = insert(:user)
      skill_class = insert(:skill_class, skill_panel: build(:skill_panel))
      skill_score = insert(:skill_score, user: user, skill_class: skill_class)

      skill_category = insert(:skill_category, skill_unit: build(:skill_unit), position: 1)
      skill = insert(:skill, skill_category: skill_category, position: 1)

      %{skill_score: skill_score, skill: skill}
    end

    test "list_skill_score_items/0 returns all skill_score_items", %{
      skill_score: skill_score,
      skill: skill
    } do
      skill_score_item = insert(:skill_score_item, skill_score: skill_score, skill: skill)

      assert SkillScores.list_skill_score_items()
             |> Enum.map(& &1.id) == [skill_score_item.id]
    end

    test "get_skill_score_item!/1 returns the skill_score_item with given id", %{
      skill_score: skill_score,
      skill: skill
    } do
      skill_score_item = insert(:skill_score_item, skill_score: skill_score, skill: skill)
      assert SkillScores.get_skill_score_item!(skill_score_item.id).id == skill_score_item.id
    end

    test "update_skill_score_item/2 with valid data updates the skill_score_item", %{
      skill_score: skill_score,
      skill: skill
    } do
      skill_score_item = insert(:skill_score_item, skill_score: skill_score, skill: skill)
      update_attrs = %{score: :high}

      assert {:ok, %SkillScoreItem{} = skill_score_item} =
               SkillScores.update_skill_score_item(skill_score_item, update_attrs)

      assert skill_score_item.score == :high
    end

    test "update_skill_score_item/2 with invalid data returns error changeset", %{
      skill_score: skill_score,
      skill: skill
    } do
      skill_score_item = insert(:skill_score_item, skill_score: skill_score, skill: skill)

      assert {:error, %Ecto.Changeset{}} =
               SkillScores.update_skill_score_item(skill_score_item, @invalid_attrs)

      assert skill_score_item.score ==
               SkillScores.get_skill_score_item!(skill_score_item.id).score
    end

    test "delete_skill_score_item/1 deletes the skill_score_item", %{
      skill_score: skill_score,
      skill: skill
    } do
      skill_score_item = insert(:skill_score_item, skill_score: skill_score, skill: skill)
      assert {:ok, %SkillScoreItem{}} = SkillScores.delete_skill_score_item(skill_score_item)

      assert_raise Ecto.NoResultsError, fn ->
        SkillScores.get_skill_score_item!(skill_score_item.id)
      end
    end

    test "change_skill_score_item/1 returns a skill_score_item changeset", %{
      skill_score: skill_score,
      skill: skill
    } do
      skill_score_item = insert(:skill_score_item, skill_score: skill_score, skill: skill)
      assert %Ecto.Changeset{} = SkillScores.change_skill_score_item(skill_score_item)
    end
  end
end
