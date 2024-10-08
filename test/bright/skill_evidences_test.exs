defmodule Bright.SkillEvidencesTest do
  use Bright.DataCase

  alias Bright.SkillEvidences

  describe "skill_evidences" do
    alias Bright.SkillEvidences.SkillEvidence

    @invalid_attrs %{progress: :invalid}

    setup do
      user = insert(:user)
      skill_category = insert(:skill_category, skill_unit: build(:skill_unit), position: 1)
      skill = insert(:skill, skill_category: skill_category, position: 1)
      valid_attrs = %{user_id: user.id, skill_id: skill.id, progress: :done}

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

    test "get_skill_evidence_by/1 returns the skill_evidence with given condition", %{
      valid_attrs: valid_attrs
    } do
      skill_evidence = insert(:skill_evidence, valid_attrs)

      assert SkillEvidences.get_skill_evidence_by(id: skill_evidence.id, progress: :done) ==
               skill_evidence

      assert SkillEvidences.get_skill_evidence_by(id: skill_evidence.id, progress: :wip) == nil
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

  describe "skill_evidence_posts" do
    alias Bright.SkillEvidences.SkillEvidencePost

    setup do
      user = insert(:user) |> with_user_profile()
      skill_category = insert(:skill_category, skill_unit: build(:skill_unit), position: 1)
      skill = insert(:skill, skill_category: skill_category, position: 1)
      skill_evidence = insert(:skill_evidence, user: user, skill: skill, progress: :wip)

      valid_attrs = %{
        user_id: user.id,
        skill_evidence_id: skill_evidence.id,
        content: "some content"
      }

      %{
        user: user,
        skill_category: skill_category,
        skill_evidence: skill_evidence,
        valid_attrs: valid_attrs
      }
    end

    test "list_skill_evidence_posts/0 returns all skill_evidence_posts", %{
      valid_attrs: valid_attrs
    } do
      skill_evidence_post = insert(:skill_evidence_post, valid_attrs)
      assert SkillEvidences.list_skill_evidence_posts() == [skill_evidence_post]
    end

    test "list_skill_evidence_posts_from_skill_evidence/1 returns skill_evidence_posts", %{
      user: user,
      skill_category: skill_category,
      skill_evidence: skill_evidence
    } do
      user_2 = insert(:user) |> with_user_profile()

      skill_evidence_post_1 =
        insert(:skill_evidence_post, user: user, skill_evidence: skill_evidence)

      skill_evidence_post_2 =
        insert(:skill_evidence_post, user: user_2, skill_evidence: skill_evidence)

      # ダミーとして別スキルの投稿を作成
      skill_dummy = insert(:skill, skill_category: skill_category, position: 2)

      skill_evidence_dummy =
        insert(:skill_evidence, user: user, skill: skill_dummy, progress: :wip)

      insert(:skill_evidence_post, user: user, skill_evidence: skill_evidence_dummy)

      hits = SkillEvidences.list_skill_evidence_posts_from_skill_evidence(skill_evidence)

      assert Enum.map(hits, & &1.id) ==
               Enum.map([skill_evidence_post_1, skill_evidence_post_2], & &1.id)

      assert Enum.all?(hits, & &1.user.user_profile)
    end

    test "get_skill_evidence_post!/1 returns the skill_evidence_post with given id", %{
      valid_attrs: valid_attrs
    } do
      skill_evidence_post = insert(:skill_evidence_post, valid_attrs)

      assert SkillEvidences.get_skill_evidence_post!(skill_evidence_post.id) ==
               skill_evidence_post
    end

    test "get_skill_evidence_post_by!/1 returns the skill_evidence_post with given condition", %{
      valid_attrs: valid_attrs
    } do
      skill_evidence_post = insert(:skill_evidence_post, valid_attrs)

      assert SkillEvidences.get_skill_evidence_post_by!(id: skill_evidence_post.id) ==
               skill_evidence_post

      assert_raise Ecto.NoResultsError, fn ->
        SkillEvidences.get_skill_evidence_post_by!(id: skill_evidence_post.id, content: "hoge")
      end
    end

    test "create_skill_evidence_post/1 with valid data creates a skill_evidence_post", %{
      user: user,
      skill_evidence: skill_evidence
    } do
      attrs = %{content: "some content"}

      assert {:ok, %SkillEvidencePost{} = skill_evidence_post} =
               SkillEvidences.create_skill_evidence_post(skill_evidence, user, attrs)

      assert skill_evidence_post.content == "some content"
    end

    test "create_skill_evidence_post/1 with invalid data returns error changeset", %{
      user: user,
      skill_evidence: skill_evidence
    } do
      attrs = %{content: nil}

      assert {:error, %Ecto.Changeset{}} =
               SkillEvidences.create_skill_evidence_post(skill_evidence, user, attrs)
    end

    test "delete_skill_evidence_post/1 deletes the skill_evidence_post", %{
      valid_attrs: valid_attrs
    } do
      skill_evidence_post = insert(:skill_evidence_post, valid_attrs)

      assert {:ok, %{delete: %SkillEvidencePost{}}} =
               SkillEvidences.delete_skill_evidence_post(skill_evidence_post)

      assert_raise Ecto.NoResultsError, fn ->
        SkillEvidences.get_skill_evidence_post!(skill_evidence_post.id)
      end
    end

    test "change_skill_evidence_post/1 returns a skill_evidence_post changeset", %{
      valid_attrs: valid_attrs
    } do
      skill_evidence_post = insert(:skill_evidence_post, valid_attrs)
      assert %Ecto.Changeset{} = SkillEvidences.change_skill_evidence_post(skill_evidence_post)
    end
  end

  describe "help/2" do
    alias Bright.Notifications.NotificationEvidence

    setup do
      skill_unit = insert(:skill_unit, name: "ユニット")
      skill_category = insert(:skill_category, skill_unit: skill_unit, name: "カテゴリ")
      skill = insert(:skill, skill_category: skill_category, name: "スキル")
      breadcrumb = "ユニット > カテゴリ > スキル"

      %{breadcrumb: breadcrumb, skill: skill}
    end

    setup %{skill: skill} do
      user = insert(:user)
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)

      %{user: user, skill_evidence: skill_evidence}
    end

    defp join_team(user, team_mate) do
      team = insert(:team)
      insert(:team_member_users, team: team, user: user)
      insert(:team_member_users, team: team, user: team_mate)
    end

    test "creates notification_evidences to team members", %{
      user: user,
      skill_evidence: skill_evidence,
      breadcrumb: breadcrumb
    } do
      # user_2, user_3はチームで、user_4のみ部外者を想定
      [user_2, user_3, user_4] = insert_list(3, :user)
      join_team(user, user_2)
      join_team(user, user_3)

      {2, _} = SkillEvidences.help(skill_evidence, user)

      assert Repo.get_by(
               NotificationEvidence,
               from_user_id: user.id,
               to_user_id: user_2.id,
               message: "#{user.name}さんから「#{breadcrumb}」のヘルプが届きました"
             )

      assert Repo.get_by(
               NotificationEvidence,
               from_user_id: user.id,
               to_user_id: user_3.id,
               message: "#{user.name}さんから「#{breadcrumb}」のヘルプが届きました"
             )

      # チーム外ユーザーへ作成されていない確認
      refute Repo.get_by(NotificationEvidence, from_user_id: user.id, to_user_id: user_4.id)
    end

    test "creates notification_evidences to supporter members", %{
      user: user,
      skill_evidence: skill_evidence
    } do
      user_2 = insert(:user)
      relate_user_and_supporter(user, user_2)

      {1, _} = SkillEvidences.help(skill_evidence, user)
      assert Repo.get_by(NotificationEvidence, from_user_id: user.id, to_user_id: user_2.id)
    end

    test "do not send supporter members if not in supporting status", %{
      user: user,
      skill_evidence: skill_evidence
    } do
      user_2 = insert(:user)
      not_supporting_statuses = ~w(requesting support_ended reject)a

      Enum.each(not_supporting_statuses, fn status ->
        relate_user_and_supporter(user, user_2, status)
        assert {0, _} = SkillEvidences.help(skill_evidence, user)
      end)
    end

    test "creates notification_evidences to supportee members", %{
      user: user,
      skill_evidence: skill_evidence
    } do
      user_2 = insert(:user)
      relate_user_and_supporter(user_2, user)

      {1, _} = SkillEvidences.help(skill_evidence, user)
      assert Repo.get_by(NotificationEvidence, from_user_id: user.id, to_user_id: user_2.id)
    end

    test "do not send supportee members if not in supporting status", %{
      user: user,
      skill_evidence: skill_evidence
    } do
      user_2 = insert(:user)
      not_supporting_statuses = ~w(requesting support_ended reject)a

      Enum.each(not_supporting_statuses, fn status ->
        relate_user_and_supporter(user_2, user, status)
        assert {0, _} = SkillEvidences.help(skill_evidence, user)
      end)
    end
  end

  describe "receive_post/2" do
    alias Bright.Notifications.NotificationEvidence

    setup do
      skill_unit = insert(:skill_unit, name: "ユニット")
      skill_category = insert(:skill_category, skill_unit: skill_unit, name: "カテゴリ")
      skill = insert(:skill, skill_category: skill_category, name: "スキル")
      breadcrumb = "ユニット > カテゴリ > スキル"

      %{breadcrumb: breadcrumb, skill: skill}
    end

    setup %{skill: skill} do
      user = insert(:user)
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)

      %{user: user, skill_evidence: skill_evidence}
    end

    test "creates notification_evidences to owner use of skill_evidence", %{
      user: user,
      skill_evidence: skill_evidence,
      breadcrumb: breadcrumb
    } do
      user_2 = insert(:user)

      {:ok, notification} = SkillEvidences.receive_post(skill_evidence, user_2)

      assert notification.from_user_id == user_2.id
      assert notification.to_user_id == user.id
      assert notification.message == "#{user_2.name}さんから「#{breadcrumb}」にメッセージが届きました"
    end
  end

  describe "can_write_skill_evidence?/2" do
    setup do
      skill_unit = insert(:skill_unit)
      skill_category = insert(:skill_category, skill_unit: skill_unit)
      skill = insert(:skill, skill_category: skill_category)

      %{skill: skill}
    end

    test "returns true if the user is same as skill_evidence owner", %{skill: skill} do
      user = insert(:user)
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)
      assert true == SkillEvidences.can_write_skill_evidence?(skill_evidence, user)
    end

    test "returns true if the user is in team members", %{skill: skill} do
      user = insert(:user)
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)
      user_2 = insert(:user)
      team = insert(:team)
      insert(:team_member_users, team: team, user: user)
      insert(:team_member_users, team: team, user: user_2)

      assert true == SkillEvidences.can_write_skill_evidence?(skill_evidence, user_2)
    end

    test "returns true if the user is in supportee members", %{skill: skill} do
      user = insert(:user)
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)

      # userを支援するuser_2を生成
      user_2 = insert(:user)
      relate_user_and_supporter(user, user_2)

      assert true == SkillEvidences.can_write_skill_evidence?(skill_evidence, user_2)
    end

    test "returns true if the user is in supporter members", %{skill: skill} do
      user = insert(:user)
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)

      # userに支援されるuser_2を生成
      user_2 = insert(:user)
      relate_user_and_supporter(user_2, user)

      assert true == SkillEvidences.can_write_skill_evidence?(skill_evidence, user_2)
    end

    test "returns false if the user is unknown", %{skill: skill} do
      user = insert(:user)
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)
      user_2 = insert(:user)

      assert false == SkillEvidences.can_write_skill_evidence?(skill_evidence, user_2)
    end
  end

  describe "can_delete_skill_evidence_post?/3" do
    setup do
      skill_unit = insert(:skill_unit)
      skill_category = insert(:skill_category, skill_unit: skill_unit)
      skill = insert(:skill, skill_category: skill_category)

      %{skill: skill}
    end

    test "returns true if the user is same as skill_evidence owner or post owner", %{skill: skill} do
      user = insert(:user)
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)

      user_2 = insert(:user)

      skill_evidence_post =
        insert(:skill_evidence_post, user: user_2, skill_evidence: skill_evidence)

      assert true ==
               SkillEvidences.can_delete_skill_evidence_post?(
                 skill_evidence_post,
                 skill_evidence,
                 user
               )

      assert true ==
               SkillEvidences.can_delete_skill_evidence_post?(
                 skill_evidence_post,
                 skill_evidence,
                 user_2
               )
    end

    test "returns false if the user is viewer", %{skill: skill} do
      user = insert(:user)
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)

      skill_evidence_post =
        insert(:skill_evidence_post, user: user, skill_evidence: skill_evidence)

      user_2 = insert(:user)

      assert false ==
               SkillEvidences.can_delete_skill_evidence_post?(
                 skill_evidence_post,
                 skill_evidence,
                 user_2
               )
    end
  end

  describe "calc_filled_percentage/2" do
    test "returns percentage floored" do
      assert 33 == SkillEvidences.calc_filled_percentage(1, 3)
      assert 66 == SkillEvidences.calc_filled_percentage(2, 3)
    end

    test "returns 0 if size is 0" do
      assert 0 == SkillEvidences.calc_filled_percentage(0, 0)
      assert 0 == SkillEvidences.calc_filled_percentage(1, 0)
    end
  end

  describe "list_recent_skill_evidences/2" do
    setup do
      skill_category = insert(:skill_category, skill_unit: build(:skill_unit), position: 1)
      skill_1 = insert(:skill, skill_category: skill_category, position: 1)
      skill_2 = insert(:skill, skill_category: skill_category, position: 2)

      %{skills: [skill_1, skill_2]}
    end

    test "returns list ordered by post time", %{
      skills: [skill_1, skill_2]
    } do
      user = insert(:user)
      skill_evidence_1 = insert(:skill_evidence, user: user, skill: skill_1)

      insert(:skill_evidence_post,
        skill_evidence: skill_evidence_1,
        user: user,
        content: "post_1",
        inserted_at: ~N[2024-08-01 09:38:00]
      )

      skill_evidence_2 = insert(:skill_evidence, user: user, skill: skill_2)

      insert(:skill_evidence_post,
        skill_evidence: skill_evidence_2,
        user: user,
        content: "post_2",
        inserted_at: ~N[2024-08-01 09:38:01]
      )

      [latest, second] = SkillEvidences.list_recent_skill_evidences([user.id])
      assert latest.id == skill_evidence_2.id
      assert second.id == skill_evidence_1.id

      # skill_evidence_1に2つ目の最新投稿を追加して並びがかわること
      insert(:skill_evidence_post,
        skill_evidence: skill_evidence_1,
        user: user,
        content: "post_1_added",
        inserted_at: ~N[2024-08-01 09:38:02]
      )

      [latest, second] = SkillEvidences.list_recent_skill_evidences([user.id])
      assert latest.id == skill_evidence_1.id
      assert second.id == skill_evidence_2.id
    end

    test "returns list with given condition", %{
      skills: [skill | _]
    } do
      user = insert(:user)
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)
      insert(:skill_evidence_post, skill_evidence: skill_evidence, user: user, content: "post")

      # 指定したuser分が返ること
      [latest] = SkillEvidences.list_recent_skill_evidences([user.id])
      assert latest.id == skill_evidence.id

      user_2 = insert(:user)
      assert [] = SkillEvidences.list_recent_skill_evidences([user_2.id])

      # 指定したsize分が返ること
      assert [] = SkillEvidences.list_recent_skill_evidences([user.id], 0)
    end
  end

  describe "truncate_post_content/2" do
    test "returns not truncated str" do
      assert "これはテスト" == SkillEvidences.truncate_post_content("これはテスト", 6)
      assert "これはテスト" == SkillEvidences.truncate_post_content("これはテスト", 7)
    end

    test "returns truncated str" do
      assert "これ..." == SkillEvidences.truncate_post_content("これはテスト", 5)
    end
  end
end
