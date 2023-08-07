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
      skill_unit_1 =
        insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 1}])

      skill_unit_2 =
        insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 2}])

      [%{skills: [skill_1]}] = insert_skill_categories_and_skills(skill_unit_1, [1])
      [%{skills: [skill_2]}] = insert_skill_categories_and_skills(skill_unit_2, [1])

      {:ok, multi_result} = SkillScores.create_skill_class_score(user, skill_class)
      assert %{skill_class_score: skill_class_score} = multi_result
      assert %{skill_scores: {2, _}} = multi_result
      assert %{skill_unit_scores: {2, _}} = multi_result

      assert skill_class_score.level == :beginner
      assert skill_class_score.percentage == 0.0

      skill_scores = Bright.Repo.preload(user, :skill_scores).skill_scores
      assert Enum.all?(skill_scores, &(&1.score == :low))

      assert Enum.map(skill_scores, & &1.skill_id)
             |> Enum.sort() == [skill_1.id, skill_2.id]

      skill_unit_scores = Bright.Repo.preload(user, :skill_unit_scores).skill_unit_scores
      assert Enum.all?(skill_unit_scores, &(&1.percentage == 0.0))
      assert Enum.all?(skill_unit_scores, &(&1.user_id == user.id))

      assert Enum.map(skill_unit_scores, & &1.skill_unit_id)
             |> Enum.sort() == [skill_unit_1.id, skill_unit_2.id]
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
      skill_unit = insert(:skill_unit)
      insert(:skill_class_unit, skill_class: skill_class, skill_unit: skill_unit)
      [%{skills: [skill_1, skill_2]}] = insert_skill_categories_and_skills(skill_unit, [2])
      insert(:skill_score, user: user, skill: skill_1, score: :low)
      insert(:skill_score, user: user, skill: skill_2, score: :high)

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
      insert(:skill_class_score, user: user, skill_class: skill_class)

      skill_category = insert(:skill_category, skill_unit: build(:skill_unit), position: 1)
      skill = insert(:skill, skill_category: skill_category, position: 1)

      %{user: user, skill: skill}
    end

    test "list_skill_scores/0 returns all skill_scores", %{
      user: user,
      skill: skill
    } do
      skill_score = insert(:skill_score, user: user, skill: skill)

      assert SkillScores.list_skill_scores()
             |> Enum.map(& &1.id) == [skill_score.id]
    end

    test "get_skill_score!/1 returns the skill_score with given id", %{
      user: user,
      skill: skill
    } do
      skill_score = insert(:skill_score, user: user, skill: skill)
      assert SkillScores.get_skill_score!(skill_score.id).id == skill_score.id
    end

    test "update_skill_score/2 with valid data updates the skill_score", %{
      user: user,
      skill: skill
    } do
      skill_score = insert(:skill_score, user: user, skill: skill)
      update_attrs = %{score: :high}

      assert {:ok, %SkillScore{} = skill_score} =
               SkillScores.update_skill_score(skill_score, update_attrs)

      assert skill_score.score == :high
    end

    test "update_skill_score/2 with invalid data returns error changeset", %{
      user: user,
      skill: skill
    } do
      skill_score = insert(:skill_score, user: user, skill: skill)

      assert {:error, %Ecto.Changeset{}} =
               SkillScores.update_skill_score(skill_score, @invalid_attrs)

      assert skill_score.score ==
               SkillScores.get_skill_score!(skill_score.id).score
    end

    test "delete_skill_score/1 deletes the skill_score", %{
      user: user,
      skill: skill
    } do
      skill_score = insert(:skill_score, user: user, skill: skill)
      assert {:ok, %SkillScore{}} = SkillScores.delete_skill_score(skill_score)

      assert_raise Ecto.NoResultsError, fn ->
        SkillScores.get_skill_score!(skill_score.id)
      end
    end

    test "change_skill_score/1 returns a skill_score changeset", %{
      user: user,
      skill: skill
    } do
      skill_score = insert(:skill_score, user: user, skill: skill)
      assert %Ecto.Changeset{} = SkillScores.change_skill_score(skill_score)
    end
  end

  describe "skill_unit_scores" do
    alias Bright.SkillScores.SkillScore

    test "update_skill_unit_score_stats without score" do
      user = insert(:user)

      # データ準備
      skill_unit = insert(:skill_unit)
      [%{skills: [_skill]}] = insert_skill_categories_and_skills(skill_unit, [1])
      skill_unit_score = insert(:skill_unit_score, user: user, skill_unit: skill_unit)

      {:ok, _results} = SkillScores.update_skill_unit_scores_stats(user, [skill_unit])

      assert %{percentage: 0.0} = Repo.get!(SkillScores.SkillUnitScore, skill_unit_score.id)
    end

    test "update_skill_unit_score_stats" do
      # 2つのskill_unitsを指定してそれぞれが適当なpercentageになっていることを確認
      user = insert(:user)

      # データ準備
      skill_unit_1 = insert(:skill_unit)
      skill_unit_2 = insert(:skill_unit)
      [%{skills: [skill_1_1]}] = insert_skill_categories_and_skills(skill_unit_1, [1])
      [%{skills: [skill_2_1, skill_2_2]}] = insert_skill_categories_and_skills(skill_unit_2, [2])
      skill_unit_score_1 = insert(:skill_unit_score, user: user, skill_unit: skill_unit_1)
      skill_unit_score_2 = insert(:skill_unit_score, user: user, skill_unit: skill_unit_2)

      # 適当なスキルスコアを用意
      insert(:skill_score, user: user, skill: skill_1_1, score: :low)
      insert(:skill_score, user: user, skill: skill_2_1, score: :high)
      insert(:skill_score, user: user, skill: skill_2_2, score: :low)

      {:ok, _results} =
        SkillScores.update_skill_unit_scores_stats(user, [skill_unit_1, skill_unit_2])

      assert %{percentage: 0.0} = Repo.get!(SkillScores.SkillUnitScore, skill_unit_score_1.id)
      assert %{percentage: 50.0} = Repo.get!(SkillScores.SkillUnitScore, skill_unit_score_2.id)
    end

    test "update_skill_unit_score_stats with dummy case" do
      # 他ユーザーのデータを参照していないことの確認用
      # user_1には:high、user_2には:lowをスキルスコアに設定
      user_1 = insert(:user)
      user_2 = insert(:user)

      # データ準備
      skill_unit = insert(:skill_unit)
      [%{skills: [skill]}] = insert_skill_categories_and_skills(skill_unit, [1])
      skill_unit_score_1 = insert(:skill_unit_score, user: user_1, skill_unit: skill_unit)
      skill_unit_score_2 = insert(:skill_unit_score, user: user_2, skill_unit: skill_unit)

      # 適当なスキルスコアを用意
      insert(:skill_score, user: user_1, skill: skill, score: :high)
      insert(:skill_score, user: user_2, skill: skill, score: :low)

      {:ok, _results} = SkillScores.update_skill_unit_scores_stats(user_1, [skill_unit])
      {:ok, _results} = SkillScores.update_skill_unit_scores_stats(user_2, [skill_unit])

      assert %{percentage: 100.0} = Repo.get!(SkillScores.SkillUnitScore, skill_unit_score_1.id)
      assert %{percentage: 0.0} = Repo.get!(SkillScores.SkillUnitScore, skill_unit_score_2.id)
    end
  end
end
