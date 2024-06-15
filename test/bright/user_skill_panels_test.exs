defmodule Bright.UserSkillPanelsTest do
  use Bright.DataCase

  alias Bright.UserSkillPanels
  alias Bright.SkillScores.SkillClassScoreLog

  describe "user_skill_panels" do
    alias Bright.UserSkillPanels.UserSkillPanel

    @invalid_attrs %{user_id: nil, skill_panel_id: nil}

    test "list_user_skill_panels/0 returns all user_skill_panels" do
      user_skill_panel = insert(:user_skill_panel)

      assert UserSkillPanels.list_user_skill_panels() == [user_skill_panel]
    end

    test "get_user_skill_panel!/1 returns the user_skill_panel with given id" do
      user_skill_panel = insert(:user_skill_panel)
      assert UserSkillPanels.get_user_skill_panel!(user_skill_panel.id) == user_skill_panel
    end

    test "create_user_skill_panel/1 with valid data creates a user_skill_panel" do
      user = insert(:user)
      skill_panel = insert(:skill_panel)
      valid_attrs = %{user_id: user.id, skill_panel_id: skill_panel.id}

      assert {:ok, %{user_skill_panel: user_skill_panel}} =
               UserSkillPanels.create_user_skill_panel(valid_attrs)

      assert user_skill_panel.user_id == user.id
      assert user_skill_panel.skill_panel_id == skill_panel.id
    end

    test "create_user_skill_panel/1 with invalid data returns error changeset" do
      assert {:error, :user_skill_panel, %Ecto.Changeset{}, %{}} =
               UserSkillPanels.create_user_skill_panel(@invalid_attrs)
    end

    test "create_user_skill_panel/1 creates skill_class_scores" do
      user = insert(:user)
      skill_panel = insert(:skill_panel)
      skill_class_1 = insert(:skill_class, skill_panel: skill_panel, class: 1)
      skill_class_2 = insert(:skill_class, skill_panel: skill_panel, class: 2)

      valid_attrs = %{user_id: user.id, skill_panel_id: skill_panel.id}
      {:ok, %{skill_class_scores: results}} = UserSkillPanels.create_user_skill_panel(valid_attrs)

      [
        %{skill_class_score_init: skill_class_score_1},
        %{skill_class_score_init: skill_class_score_2}
      ] = results

      assert skill_class_score_1.user_id == user.id
      assert skill_class_score_1.skill_class_id == skill_class_1.id
      assert skill_class_score_1.percentage == 0.0
      assert skill_class_score_1.level == :beginner

      assert skill_class_score_2.user_id == user.id
      assert skill_class_score_2.skill_class_id == skill_class_2.id
      assert skill_class_score_2.percentage == 0.0
      assert skill_class_score_2.level == :beginner
    end

    test "create_user_skill_panel/1 creates skill_class_scores when skill_scores are already existing" do
      user = insert(:user)
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)
      skill_unit = insert(:skill_unit)
      [%{skills: [skill]}] = insert_skill_categories_and_skills(skill_unit, [1])
      insert(:skill_class_unit, skill_class: skill_class, skill_unit: skill_unit)

      # 事前にスキルスコア用意（別のスキルパネルで習得済みという扱い）
      insert(:skill_score, user: user, skill: skill, score: :high)

      valid_attrs = %{user_id: user.id, skill_panel_id: skill_panel.id}
      {:ok, %{skill_class_scores: results}} = UserSkillPanels.create_user_skill_panel(valid_attrs)

      [%{skill_class_score: %{update_skill_class_score: skill_class_score}}] = results
      assert skill_class_score.percentage == 100.0
      assert skill_class_score.level == :skilled

      # スキルクラススコアのログ作成確認
      assert %{percentage: 100.0} =
               Repo.get_by(SkillClassScoreLog, %{
                 user_id: user.id,
                 skill_class_id: skill_class.id,
                 date: Date.utc_today()
               })
    end

    test "update_user_skill_panel/2 with valid data updates the user_skill_panel" do
      user_skill_panel = insert(:user_skill_panel)
      user = insert(:user)
      skill_panel = insert(:skill_panel)
      update_attrs = %{user_id: user.id, skill_panel_id: skill_panel.id}

      assert {:ok, %UserSkillPanel{} = user_skill_panel} =
               UserSkillPanels.update_user_skill_panel(user_skill_panel, update_attrs)

      assert user_skill_panel.user_id == user.id
      assert user_skill_panel.skill_panel_id == skill_panel.id
    end

    test "update_user_skill_panel/2 with invalid data returns error changeset" do
      user_skill_panel = insert(:user_skill_panel)

      assert {:error, %Ecto.Changeset{}} =
               UserSkillPanels.update_user_skill_panel(user_skill_panel, @invalid_attrs)

      assert user_skill_panel == UserSkillPanels.get_user_skill_panel!(user_skill_panel.id)
    end

    test "delete_user_skill_panel/1 deletes the user_skill_panel" do
      user_skill_panel = insert(:user_skill_panel)
      assert {:ok, %UserSkillPanel{}} = UserSkillPanels.delete_user_skill_panel(user_skill_panel)

      assert_raise Ecto.NoResultsError, fn ->
        UserSkillPanels.get_user_skill_panel!(user_skill_panel.id)
      end
    end

    test "change_user_skill_panel/1 returns a user_skill_panel changeset" do
      user_skill_panel = insert(:user_skill_panel)
      assert %Ecto.Changeset{} = UserSkillPanels.change_user_skill_panel(user_skill_panel)
    end

    test "get_star! and set_star" do
      user_skill_panel = insert(:user_skill_panel)
      user_skill_panel2 = insert(:user_skill_panel)
      refute user_skill_panel.is_star
      refute UserSkillPanels.get_star!(user_skill_panel.user_id, user_skill_panel.skill_panel_id)
      assert {:ok, %UserSkillPanel{}} = UserSkillPanels.set_star(user_skill_panel.user, user_skill_panel.skill_panel, true)
      assert UserSkillPanels.get_star!(user_skill_panel.user_id, user_skill_panel.skill_panel_id)
      refute UserSkillPanels.get_star!(user_skill_panel2.user_id, user_skill_panel2.skill_panel_id)
    end

  end
end
