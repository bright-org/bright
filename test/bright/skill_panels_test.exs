defmodule Bright.SkillPanelsTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.SkillPanels
  alias Bright.UserSkillPanels

  alias Bright.Teams
  alias Bright.TeamTestHelper

  describe "skill_panels" do
    alias Bright.SkillPanels.SkillPanel

    @invalid_attrs params_for(:skill_panel) |> Map.put(:name, nil)

    test "list_skill_panels/0 returns all skill_panels" do
      skill_panel = insert(:skill_panel)
      assert SkillPanels.list_skill_panels() == [skill_panel]
    end

    test "list_users_skill_panels_by_career_field preloads user's skill_class_scores" do
      # 指定したユーザーのスキルクラススコアを取得することの確認
      user_1 = insert(:user)
      user_2 = insert(:user)
      career_field_name = "engineer"

      # キャリアフィールドからスキルクラスまでの用意
      career_field = insert(:career_field, name_en: career_field_name)
      job = insert(:job)
      insert(:career_field_job, career_field: career_field, job: job)
      skill_panel = insert(:skill_panel)
      insert(:job_skill_panel, job: job, skill_panel: skill_panel)
      skill_class_1 = insert(:skill_class, skill_panel: skill_panel, class: 1)
      skill_class_2 = insert(:skill_class, skill_panel: skill_panel, class: 2)

      # 保有スキルパネルとスキルクラススコアの用意
      # user_1 はクラス１まで
      # user_2 はクラス２まで
      insert(:user_skill_panel, user: user_1, skill_panel: skill_panel)
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel)
      insert(:skill_class_score, user: user_1, skill_class: skill_class_1, percentage: 20.0)
      insert(:skill_class_score, user: user_2, skill_class: skill_class_1, percentage: 40.0)
      insert(:skill_class_score, user: user_2, skill_class: skill_class_2, percentage: 10.0)

      # uesr_1 について、スキルクラスは１つまでロードされていること
      ret = SkillPanels.list_users_skill_panels_by_career_field(user_1.id, career_field_name)
      assert %{entries: [ret_skill_panel]} = ret
      assert [ret_skill_class_1, ret_skill_class_2] = ret_skill_panel.skill_classes
      assert 20.0 == hd(ret_skill_class_1.skill_class_scores).percentage
      assert [] == ret_skill_class_2.skill_class_scores

      # uesr_2 について、スキルクラスは２つまでロードされていること
      ret = SkillPanels.list_users_skill_panels_by_career_field(user_2.id, career_field_name)
      assert %{entries: [ret_skill_panel]} = ret
      assert [ret_skill_class_1, ret_skill_class_2] = ret_skill_panel.skill_classes
      assert 40.0 == hd(ret_skill_class_1.skill_class_scores).percentage
      assert 10.0 == hd(ret_skill_class_2.skill_class_scores).percentage
    end

    test "get_skill_panel!/1 returns the skill_panel with given id" do
      skill_panel = insert(:skill_panel)
      assert SkillPanels.get_skill_panel!(skill_panel.id) == skill_panel
    end

    test "create_skill_panel/1 with valid data creates a skill_panel" do
      valid_attrs = params_for(:skill_panel)

      assert {:ok, %SkillPanel{} = skill_panel} = SkillPanels.create_skill_panel(valid_attrs)
      assert skill_panel.name == valid_attrs.name
    end

    test "create_skill_panel/1 with skill_classes" do
      valid_attrs =
        params_for(:skill_panel)
        |> Map.put(:skill_classes, [
          params_for(:skill_class, class: nil),
          params_for(:skill_class, class: nil)
        ])

      {:ok, %SkillPanel{} = skill_panel} = SkillPanels.create_skill_panel(valid_attrs)

      [skill_class_1, skill_class_2] = skill_panel.skill_classes
      [valid_attrs_1, valid_attrs_2] = valid_attrs.skill_classes

      assert skill_class_1.name == valid_attrs_1.name
      assert skill_class_1.class == 1
      assert skill_class_2.name == valid_attrs_2.name
      assert skill_class_2.class == 2
    end

    test "create_skill_panel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SkillPanels.create_skill_panel(@invalid_attrs)
    end

    test "update_skill_panel/2 with valid data updates the skill_panel" do
      skill_panel = insert(:skill_panel)
      update_attrs = params_for(:skill_panel)

      assert {:ok, %SkillPanel{} = skill_panel} =
               SkillPanels.update_skill_panel(skill_panel, update_attrs)

      assert skill_panel.name == update_attrs.name
    end

    test "update_skill_panel/2 with invalid data returns error changeset" do
      skill_panel = insert(:skill_panel)

      assert {:error, %Ecto.Changeset{}} =
               SkillPanels.update_skill_panel(skill_panel, @invalid_attrs)

      assert skill_panel == SkillPanels.get_skill_panel!(skill_panel.id)
    end

    test "delete_skill_panel/1 deletes the skill_panel with skill_classes" do
      skill_panel = insert(:skill_panel)
      insert_pair(:skill_class, skill_panel: skill_panel)

      assert {:ok, %{skill_panel: %SkillPanel{}, skill_classes: {2, _}}} =
               SkillPanels.delete_skill_panel(skill_panel)

      assert_raise Ecto.NoResultsError, fn -> SkillPanels.get_skill_panel!(skill_panel.id) end
    end

    test "change_skill_panel/1 returns a skill_panel changeset" do
      skill_panel = insert(:skill_panel)
      assert %Ecto.Changeset{} = SkillPanels.change_skill_panel(skill_panel)
    end

    test "get_user_skill_panel!/1 returns the skill_panel with given user and id" do
      user = insert(:user)
      skill_panel = insert(:skill_panel)
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)
      assert SkillPanels.get_user_skill_panel!(user, skill_panel.id) == skill_panel
    end

    test "get_user_skill_panel!/1 raises NoResultsError" do
      [user, user_2] = insert_pair(:user)
      skill_panel = insert(:skill_panel)
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)

      assert_raise Ecto.NoResultsError, fn ->
        SkillPanels.get_user_skill_panel!(user_2, skill_panel.id)
      end
    end

    test "get_user_latest_skill_panel/1 returns the skill_panel with given user" do
      user = insert(:user)
      [skill_panel_1, skill_panel_2] = insert_pair(:skill_panel)

      [skill_panel_1, skill_panel_2]
      |> Enum.each(&insert(:user_skill_panel, user: user, skill_panel: &1))

      :timer.sleep(1000)
      UserSkillPanels.touch_user_skill_panel_updated(user, skill_panel_1)
      assert SkillPanels.get_user_latest_skill_panel(user) == skill_panel_1
    end
  end

  describe "skill_classes" do
    test "list_skill_classs/0 returns all skill_classs" do
      skill_class = insert(:skill_class, skill_panel: build(:skill_panel), class: 1)

      assert SkillPanels.list_skill_classes()
             |> Bright.Repo.preload(:skill_panel) == [skill_class]
    end
  end

  describe "list_team_member_users_skill_panels_by_career_field/3" do
    test "select success" do
      team_name = Faker.Lorem.word()
      user_1 = insert(:user)
      user_2 = insert(:user)
      career_field_name = "engineer"

      # キャリアフィールドからスキルクラスまでの用意
      career_field = insert(:career_field, name_en: career_field_name)
      job = insert(:job)
      insert(:career_field_job, career_field: career_field, job: job)
      skill_panel_1 = insert(:skill_panel)
      insert(:job_skill_panel, job: job, skill_panel: skill_panel_1)
      skill_class_1_1 = insert(:skill_class, skill_panel: skill_panel_1, class: 1)

      skill_panel_2 = insert(:skill_panel)
      insert(:job_skill_panel, job: job, skill_panel: skill_panel_2)
      skill_class_2_1 = insert(:skill_class, skill_panel: skill_panel_2, class: 1)
      skill_class_2_2 = insert(:skill_class, skill_panel: skill_panel_2, class: 2)

      # 保有スキルパネルとスキルクラススコアの用意
      # user_1 は最初のスキルパネルのクラス１まで
      # user_2 は最初のスキルパネルのクラス１と二つ目のスキルパネルのクラス２まで
      insert(:user_skill_panel, user: user_1, skill_panel: skill_panel_1)
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel_2)
      insert(:skill_class_score, user: user_1, skill_class: skill_class_1_1, percentage: 20.0)
      insert(:skill_class_score, user: user_2, skill_class: skill_class_1_1, percentage: 30.0)
      insert(:skill_class_score, user: user_2, skill_class: skill_class_2_1, percentage: 40.0)
      insert(:skill_class_score, user: user_2, skill_class: skill_class_2_2, percentage: 10.0)

      # チームを作成
      assert {:ok, team, team_member_user_attrs} =
               Teams.create_team_multi(team_name, user_1, [user_2])

      # 未承認状態ではチーム作成者のスキルパネルしか取得できない
      page =
        SkillPanels.list_team_member_users_skill_panels_by_career_field(
          team.id,
          career_field_name
        )

      assert page.total_entries == 1

      [skill_panel] = page.entries
      assert skill_panel.id == skill_panel_1.id

      # 承認するとユーザー２のスキルパネルも取得対象となる
      TeamTestHelper.cofirm_invitation(team_member_user_attrs)

      page2 =
        SkillPanels.list_team_member_users_skill_panels_by_career_field(
          team.id,
          career_field_name
        )

      assert page2.total_entries == 2
    end
  end
end
