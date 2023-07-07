defmodule Bright.SkillScoresTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.SkillScores

  setup do
    user = insert(:user)
    skill_class = insert(:skill_class, skill_panel: build(:skill_panel))

    %{user: user, skill_class: skill_class}
  end

  describe "skill_scores" do
    alias Bright.SkillScores.SkillScore

    @invalid_attrs %{level: :invalid}

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
      skill_score = %{id: id} = insert(:skill_score, user: user, skill_class: skill_class)
      assert id == SkillScores.get_skill_score!(skill_score.id).id
    end

    test "create_skill_score/1 with valid data creates a skill_score", %{
      user: user,
      skill_class: skill_class
    } do
      valid_attrs = %{level: :middle, user_id: user.id, skill_class_id: skill_class.id}

      assert {:ok, %SkillScore{} = skill_score} = SkillScores.create_skill_score(valid_attrs)
      assert skill_score.level == :middle
    end

    test "create_skill_score/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SkillScores.create_skill_score(@invalid_attrs)
    end

    test "update_skill_score/2 with valid data updates the skill_score", %{
      user: user,
      skill_class: skill_class
    } do
      skill_score = insert(:skill_score, user: user, skill_class: skill_class)
      update_attrs = %{level: :middle}

      assert {:ok, %SkillScore{} = skill_score} =
               SkillScores.update_skill_score(skill_score, update_attrs)

      assert skill_score.level == :middle
    end

    test "update_skill_score/2 with invalid data returns error changeset", %{
      user: user,
      skill_class: skill_class
    } do
      skill_score = %{level: level} = insert(:skill_score, user: user, skill_class: skill_class)

      assert {:error, %Ecto.Changeset{}} =
               SkillScores.update_skill_score(skill_score, @invalid_attrs)

      assert %{level: ^level} = SkillScores.get_skill_score!(skill_score.id)
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
end
