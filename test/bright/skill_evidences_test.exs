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

      assert {:ok, %SkillEvidencePost{}} =
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
end
