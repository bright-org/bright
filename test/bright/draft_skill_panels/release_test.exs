defmodule Bright.DraftSkillPanels.ReleaseTest do
  use Bright.DataCase, async: true

  import Mock

  alias Bright.DraftSkillPanels.Release

  alias Bright.Repo
  alias Bright.SkillPanels.SkillClass
  alias Bright.SkillPanels.SkillPanel
  alias Bright.SkillUnits.SkillUnit
  alias Bright.SkillUnits.SkillCategory
  alias Bright.SkillUnits.Skill
  alias Bright.SkillUnits.SkillClassUnit

  # mock date固定, 新規作成時にlocked_dateが現在時参照で決まるため
  defp date_mock do
    {
      Date,
      [:passthrough],
      [
        utc_today: fn -> ~D[2024-08-29] end
      ]
    }
  end

  # テストデータ生成の共通処理
  defp create_draft_skill do
    draft_skill_unit = insert(:draft_skill_unit, name: "draft")

    draft_skill_category =
      insert(:draft_skill_category, draft_skill_unit: draft_skill_unit, name: "draft")

    draft_skill = insert(:draft_skill, draft_skill_category: draft_skill_category, name: "draft")

    {draft_skill_unit, draft_skill_category, draft_skill}
  end

  defp create_skill_with_draft do
    {draft_skill_unit, draft_skill_category, draft_skill} = drafts = create_draft_skill()
    skill_unit = insert(:skill_unit, trace_id: draft_skill_unit.trace_id, name: "current")

    skill_category =
      insert(:skill_category,
        skill_unit: skill_unit,
        trace_id: draft_skill_category.trace_id,
        name: "current"
      )

    skill =
      insert(:skill,
        skill_category: skill_category,
        trace_id: draft_skill.trace_id,
        name: "current"
      )

    {drafts, {skill_unit, skill_category, skill}}
  end

  defp create_skill do
    skill_unit = insert(:skill_unit)
    skill_category = insert(:skill_category, skill_unit: skill_unit)
    skill = insert(:skill, skill_category: skill_category)

    {skill_unit, skill_category, skill}
  end

  setup do
    %{skill_panel: insert(:draft_skill_panel)}
  end

  test "just runs", ctx do
    assert {:ok, _} = Release.commit(ctx.skill_panel)
  end

  describe "commit structures" do
    test "inserts skill_class", ctx do
      # スキルクラスの新規作成確認
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      with_mocks([date_mock()]) do
        Release.commit(ctx.skill_panel)

        new_one = Repo.get_by!(SkillClass, trace_id: draft_skill_class.trace_id)
        assert new_one.name == draft_skill_class.name
        assert new_one.class == draft_skill_class.class
        assert new_one.skill_panel_id == draft_skill_class.skill_panel_id
        assert new_one.locked_date == ~D[2024-07-01]
      end
    end

    test "updates skill_classes", ctx do
      # スキルクラスの更新確認
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class.trace_id
        )

      Release.commit(ctx.skill_panel)

      updated_one = Repo.get_by!(SkillClass, id: skill_class.id)
      assert updated_one.name == draft_skill_class.name
    end

    test "inserts skill_unit / skill_category / skill", ctx do
      # ベーシックなスキルユニット以下の新規作成確認
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)
      {draft_skill_unit, draft_skill_category, draft_skill} = create_draft_skill()

      draft_skill_class_unit =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class,
          draft_skill_unit: draft_skill_unit
        )

      with_mocks([date_mock()]) do
        Release.commit(ctx.skill_panel)

        # 作成されていることを確認
        new_skill_unit = Repo.get_by!(SkillUnit, trace_id: draft_skill_unit.trace_id)
        new_skill_category = Repo.get_by!(SkillCategory, trace_id: draft_skill_category.trace_id)
        new_skill = Repo.get_by!(Skill, trace_id: draft_skill.trace_id)
        new_skill_class = Repo.get_by!(SkillClass, trace_id: draft_skill_class.trace_id)

        new_skill_class_unit =
          Repo.get_by!(SkillClassUnit, trace_id: draft_skill_class_unit.trace_id)

        assert new_skill_unit.name == draft_skill_unit.name
        assert new_skill_unit.locked_date == ~D[2024-07-01]

        assert new_skill_category.name == draft_skill_category.name
        assert new_skill_category.position == draft_skill_category.position
        assert new_skill_category.skill_unit_id == new_skill_unit.id

        assert new_skill.name == draft_skill.name
        assert new_skill.position == draft_skill.position
        assert new_skill.skill_category_id == new_skill_category.id

        assert new_skill_class_unit.skill_class_id == new_skill_class.id
        assert new_skill_class_unit.skill_unit_id == new_skill_unit.id
      end
    end

    test "updates skill_unit / skill_category / skill", ctx do
      # ベーシックなスキルユニット以下の更新確認
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class.trace_id,
          name: "before"
        )

      {
        {draft_skill_unit, draft_skill_category, draft_skill},
        {skill_unit, skill_category, skill}
      } = create_skill_with_draft()

      insert(:draft_skill_class_unit,
        draft_skill_class: draft_skill_class,
        draft_skill_unit: draft_skill_unit
      )

      insert(:skill_class_unit, skill_class: skill_class, skill_unit: skill_unit)

      Release.commit(ctx.skill_panel)

      # ドラフト内容に更新されていることを確認
      updated_skill_unit = Repo.get_by!(SkillUnit, trace_id: draft_skill_unit.trace_id)

      updated_skill_category =
        Repo.get_by!(SkillCategory, trace_id: draft_skill_category.trace_id)

      updated_skill = Repo.get_by!(Skill, trace_id: draft_skill.trace_id)

      assert updated_skill_unit.id == skill_unit.id
      assert updated_skill_unit.name == draft_skill_unit.name

      assert updated_skill_category.id == skill_category.id
      assert updated_skill_category.name == draft_skill_category.name
      assert updated_skill_category.position == draft_skill_category.position
      assert updated_skill_category.skill_unit_id == skill_unit.id

      assert updated_skill.id == skill.id
      assert updated_skill.name == draft_skill.name
      assert updated_skill.position == draft_skill.position
      assert updated_skill.skill_category_id == skill_category.id
    end

    test "deletes skill_unit / skill_category / skill", ctx do
      skill_class = insert(:skill_class, skill_panel_id: ctx.skill_panel.id)
      {skill_unit, skill_category, skill} = create_skill()
      insert(:skill_class_unit, skill_class: skill_class, skill_unit: skill_unit)

      Release.commit(ctx.skill_panel)

      # ドラフトには何も残っていないので全て削除されていること
      refute Repo.get_by(SkillUnit, id: skill_unit.id)
      refute Repo.get_by(SkillCategory, id: skill_category.id)
      refute Repo.get_by(Skill, id: skill.id)
    end

    test "adds skill_unit by move", ctx do
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class.trace_id
        )

      {
        {draft_skill_unit, _draft_skill_category, _draft_skill},
        {skill_unit, _skill_category, _skill}
      } = create_skill_with_draft()

      skill_panel_from = insert(:skill_panel)
      draft_skill_class_from = insert(:draft_skill_class, skill_panel_id: skill_panel_from.id)

      skill_class_from =
        insert(:skill_class,
          skill_panel: skill_panel_from,
          trace_id: draft_skill_class_from.trace_id
        )

      #   本番上はスキルユニットを別スキルパネルに存在させ、ドラフト上は移動済みとする
      draft_skill_class_unit =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class,
          draft_skill_unit: draft_skill_unit
        )

      insert(:skill_class_unit,
        skill_class: skill_class_from,
        skill_unit: skill_unit,
        trace_id: draft_skill_class_unit.trace_id
      )

      Release.commit(ctx.skill_panel)

      # 処理後データ状況（スキルユニット移動）の確認
      skill_class_unit = Repo.get_by(SkillClassUnit, skill_unit_id: skill_unit.id)
      assert skill_class_unit.skill_class_id == skill_class.id
    end

    test "removes skill_unit by move", ctx do
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class.trace_id
        )

      {
        {draft_skill_unit, _draft_skill_category, _draft_skill},
        {skill_unit, _skill_category, _skill}
      } = create_skill_with_draft()

      skill_panel_to = insert(:skill_panel)
      draft_skill_class_to = insert(:draft_skill_class, skill_panel_id: skill_panel_to.id)

      skill_class_to =
        insert(:skill_class, skill_panel: skill_panel_to, trace_id: draft_skill_class_to.trace_id)

      #   本番上はスキルユニットを本スキルパネルに存在させ、ドラフト上は移動済みとする
      draft_skill_class_unit =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class_to,
          draft_skill_unit: draft_skill_unit
        )

      insert(:skill_class_unit,
        skill_class: skill_class,
        skill_unit: skill_unit,
        trace_id: draft_skill_class_unit.trace_id
      )

      Release.commit(ctx.skill_panel)

      # 処理後データ状況（スキルユニット移動）の反映確認
      skill_class_unit = Repo.get_by(SkillClassUnit, skill_unit_id: skill_unit.id)
      assert skill_class_unit.skill_class_id == skill_class_to.id
    end

    test "adds skill_category by move", ctx do
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class.trace_id
        )

      {
        {draft_skill_unit, _draft_skill_category, _draft_skill},
        {skill_unit, _skill_category, _skill}
      } = create_skill_with_draft()

      draft_skill_class_unit =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class,
          draft_skill_unit: draft_skill_unit
        )

      insert(:skill_class_unit,
        skill_class: skill_class,
        skill_unit: skill_unit,
        trace_id: draft_skill_class_unit.trace_id
      )

      # 移動元とドラフトデータ上での移動の準備
      draft_skill_class_2 = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class_2 =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class_2.trace_id
        )

      {
        {draft_skill_unit_2, draft_skill_category_2, _draft_skill_2},
        {skill_unit_2, skill_category_2, _skill_2}
      } = create_skill_with_draft()

      draft_skill_class_unit_2 =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class_2,
          draft_skill_unit: draft_skill_unit_2
        )

      insert(:skill_class_unit,
        skill_class: skill_class_2,
        skill_unit: skill_unit_2,
        trace_id: draft_skill_class_unit_2.trace_id
      )

      #   ドラフト上での移動処理相当のupdate
      Repo.update(
        Ecto.Changeset.change(draft_skill_category_2, draft_skill_unit_id: draft_skill_unit.id)
      )

      Release.commit(ctx.skill_panel)

      # 処理後データ状況（スキルカテゴリ移動）の反映確認
      skill_category_2 = Repo.get_by(SkillCategory, id: skill_category_2.id)
      assert skill_category_2.skill_unit_id == skill_unit.id
    end

    test "removes skill_category by move", ctx do
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class.trace_id
        )

      {
        {draft_skill_unit, draft_skill_category, _draft_skill},
        {skill_unit, skill_category, _skill}
      } = create_skill_with_draft()

      draft_skill_class_unit =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class,
          draft_skill_unit: draft_skill_unit
        )

      insert(:skill_class_unit,
        skill_class: skill_class,
        skill_unit: skill_unit,
        trace_id: draft_skill_class_unit.trace_id
      )

      # 移動先とドラフトデータ上での移動の準備
      skill_panel_2 = insert(:skill_panel)
      draft_skill_class_2 = insert(:draft_skill_class, skill_panel_id: skill_panel_2.id)

      skill_class_2 =
        insert(:skill_class,
          skill_panel_id: skill_panel_2.id,
          trace_id: draft_skill_class_2.trace_id
        )

      {
        {draft_skill_unit_2, _draft_skill_category_2, _draft_skill_2},
        {skill_unit_2, _skill_category_2, _skill_2}
      } = create_skill_with_draft()

      draft_skill_class_unit_2 =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class_2,
          draft_skill_unit: draft_skill_unit_2
        )

      insert(:skill_class_unit,
        skill_class: skill_class_2,
        skill_unit: skill_unit_2,
        trace_id: draft_skill_class_unit_2.trace_id
      )

      #   ドラフト上での移動処理相当のupdate
      Repo.update(
        Ecto.Changeset.change(draft_skill_category, draft_skill_unit_id: draft_skill_unit_2.id)
      )

      Release.commit(ctx.skill_panel)

      # 処理後データ状況（スキルカテゴリ移動）の反映確認
      skill_category = Repo.get_by(SkillCategory, id: skill_category.id)
      assert skill_category.skill_unit_id == skill_unit_2.id
    end

    test "adds skill by move", ctx do
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class.trace_id
        )

      {
        {draft_skill_unit, draft_skill_category, _draft_skill},
        {skill_unit, skill_category, _skill}
      } = create_skill_with_draft()

      draft_skill_class_unit =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class,
          draft_skill_unit: draft_skill_unit
        )

      insert(:skill_class_unit,
        skill_class: skill_class,
        skill_unit: skill_unit,
        trace_id: draft_skill_class_unit.trace_id
      )

      # 移動元とドラフトデータ上での移動の準備
      draft_skill_class_2 = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class_2 =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class_2.trace_id
        )

      {
        {draft_skill_unit_2, _draft_skill_category_2, draft_skill_2},
        {skill_unit_2, _skill_category_2, skill_2}
      } = create_skill_with_draft()

      draft_skill_class_unit_2 =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class_2,
          draft_skill_unit: draft_skill_unit_2
        )

      insert(:skill_class_unit,
        skill_class: skill_class_2,
        skill_unit: skill_unit_2,
        trace_id: draft_skill_class_unit_2.trace_id
      )

      #   ドラフト上での移動処理相当のupdate
      Repo.update(
        Ecto.Changeset.change(draft_skill_2, draft_skill_category_id: draft_skill_category.id)
      )

      Release.commit(ctx.skill_panel)

      # 処理後データ状況（スキル移動）の反映確認
      skill_2 = Repo.get_by(Skill, id: skill_2.id)
      assert skill_2.skill_category_id == skill_category.id
    end

    test "removes skill by move", ctx do
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class.trace_id
        )

      {
        {draft_skill_unit, _draft_skill_category, draft_skill},
        {skill_unit, _skill_category, skill}
      } = create_skill_with_draft()

      draft_skill_class_unit =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class,
          draft_skill_unit: draft_skill_unit
        )

      insert(:skill_class_unit,
        skill_class: skill_class,
        skill_unit: skill_unit,
        trace_id: draft_skill_class_unit.trace_id
      )

      # 移動元とドラフトデータ上での移動の準備
      skill_panel_2 = insert(:skill_panel)
      draft_skill_class_2 = insert(:draft_skill_class, skill_panel_id: skill_panel_2.id)

      skill_class_2 =
        insert(:skill_class,
          skill_panel_id: skill_panel_2.id,
          trace_id: draft_skill_class_2.trace_id
        )

      {
        {draft_skill_unit_2, draft_skill_category_2, _draft_skill_2},
        {skill_unit_2, skill_category_2, _skill_2}
      } = create_skill_with_draft()

      draft_skill_class_unit_2 =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class_2,
          draft_skill_unit: draft_skill_unit_2
        )

      insert(:skill_class_unit,
        skill_class: skill_class_2,
        skill_unit: skill_unit_2,
        trace_id: draft_skill_class_unit_2.trace_id
      )

      #   ドラフト上での移動処理相当のupdate
      Repo.update(
        Ecto.Changeset.change(draft_skill, draft_skill_category_id: draft_skill_category_2.id)
      )

      Release.commit(ctx.skill_panel)

      # 処理後データ状況（スキル移動）の反映確認
      skill = Repo.get_by(Skill, id: skill.id)
      assert skill.skill_category_id == skill_category_2.id
    end
  end

  describe "relations" do
    alias Bright.SkillReferences.SkillReference
    alias Bright.SkillExams.SkillExam
    alias Bright.SkillScores.SkillScore
    alias Bright.SkillEvidences.SkillEvidence
    alias Bright.SkillEvidences.SkillEvidencePost

    test "removes skill with relations such as score", ctx do
      skill_class = insert(:skill_class, skill_panel_id: ctx.skill_panel.id)
      {skill_unit, _skill_category, skill} = create_skill()
      insert(:skill_class_unit, skill_class: skill_class, skill_unit: skill_unit)

      # スキルまわりの関連生成
      skill_reference = insert(:skill_reference, skill: skill)
      skill_exam = insert(:skill_exam, skill: skill)
      user = insert(:user)
      skill_score = insert(:skill_score, skill: skill, user: user, score: :high)
      skill_evidence = insert(:skill_evidence, skill: skill, user: user)

      skill_evidence_post =
        insert(:skill_evidence_post, skill_evidence: skill_evidence, user: user)

      Release.commit(ctx.skill_panel)

      # スキルと合わせて削除されること
      refute Repo.get_by(Skill, id: skill.id)
      refute Repo.get_by(SkillReference, id: skill_reference.id)
      refute Repo.get_by(SkillExam, id: skill_exam.id)
      refute Repo.get_by(SkillScore, id: skill_score.id)
      refute Repo.get_by(SkillEvidence, id: skill_evidence.id)
      refute Repo.get_by(SkillEvidencePost, id: skill_evidence_post.id)
    end

    test "does not affects skill relations by move", ctx do
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class.trace_id
        )

      {
        {draft_skill_unit, draft_skill_category, _draft_skill},
        {skill_unit, skill_category, _skill}
      } = create_skill_with_draft()

      draft_skill_class_unit =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class,
          draft_skill_unit: draft_skill_unit
        )

      insert(:skill_class_unit,
        skill_class: skill_class,
        skill_unit: skill_unit,
        trace_id: draft_skill_class_unit.trace_id
      )

      # 移動元とドラフトデータ上での移動の準備
      draft_skill_class_2 = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class_2 =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class_2.trace_id
        )

      {
        {draft_skill_unit_2, _draft_skill_category_2, draft_skill_2},
        {skill_unit_2, _skill_category_2, skill_2}
      } = create_skill_with_draft()

      draft_skill_class_unit_2 =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class_2,
          draft_skill_unit: draft_skill_unit_2
        )

      insert(:skill_class_unit,
        skill_class: skill_class_2,
        skill_unit: skill_unit_2,
        trace_id: draft_skill_class_unit_2.trace_id
      )

      #   移動元スキルに関連設定
      skill_reference = insert(:skill_reference, skill: skill_2)
      skill_exam = insert(:skill_exam, skill: skill_2)
      user = insert(:user)
      skill_score = insert(:skill_score, skill: skill_2, user: user, score: :high)
      skill_evidence = insert(:skill_evidence, skill: skill_2, user: user)

      #   ドラフト上での移動処理相当のupdate
      Repo.update(
        Ecto.Changeset.change(draft_skill_2, draft_skill_category_id: draft_skill_category.id)
      )

      Release.commit(ctx.skill_panel)

      # 移動後も特に関連が影響を受けていないこと
      assert Repo.get_by(Skill, id: skill_2.id, skill_category_id: skill_category.id)
      assert Repo.get_by(SkillReference, id: skill_reference.id, skill_id: skill_2.id)
      assert Repo.get_by(SkillExam, id: skill_exam.id, skill_id: skill_2.id)
      assert Repo.get_by(SkillScore, id: skill_score.id, skill_id: skill_2.id)
      assert Repo.get_by(SkillEvidence, id: skill_evidence.id, skill_id: skill_2.id)
    end
  end

  describe "scores update" do
    alias Bright.SkillScores.SkillClassScore
    alias Bright.SkillScores.SkillUnitScore

    test "updates skill_classes.score", ctx do
      # 100%のスキルユニットを空のスキルクラスに移動して確認している
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class.trace_id
        )

      {
        {draft_skill_unit, _draft_skill_category, _draft_skill},
        {skill_unit, _skill_category, skill}
      } = create_skill_with_draft()

      skill_panel_from = insert(:skill_panel)
      draft_skill_class_from = insert(:draft_skill_class, skill_panel_id: skill_panel_from.id)

      skill_class_from =
        insert(:skill_class,
          skill_panel: skill_panel_from,
          trace_id: draft_skill_class_from.trace_id
        )

      #   本番上はスキルユニットを別スキルパネルに存在させ、ドラフト上は移動済みとする
      draft_skill_class_unit =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class,
          draft_skill_unit: draft_skill_unit
        )

      insert(:skill_class_unit,
        skill_class: skill_class_from,
        skill_unit: skill_unit,
        trace_id: draft_skill_class_unit.trace_id
      )

      # 処理前のスコア準備
      user = insert(:user)
      skill_panel = Repo.get(SkillPanel, ctx.skill_panel.id)
      insert(:user_skill_panel, skill_panel: skill_panel, user: user)
      insert(:user_skill_panel, skill_panel: skill_panel_from, user: user)
      insert(:skill_score, skill: skill, user: user, score: :high)

      skill_class_score =
        insert(:skill_class_score, skill_class: skill_class, user: user, percentage: 0)

      Release.commit(ctx.skill_panel)

      # 処理後データ状況（スキルユニットスコア）の確認
      skill_class_score = Repo.get_by(SkillClassScore, id: skill_class_score.id)
      assert skill_class_score.percentage == 100
    end

    test "updates skill_units.score", ctx do
      # 0/1で0%のスキルユニットにhighスキルを1つ移動して50%になることを確認している
      draft_skill_class = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class.trace_id
        )

      {
        {draft_skill_unit, draft_skill_category, _draft_skill},
        {skill_unit, _skill_category, skill}
      } = create_skill_with_draft()

      draft_skill_class_unit =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class,
          draft_skill_unit: draft_skill_unit
        )

      insert(:skill_class_unit,
        skill_class: skill_class,
        skill_unit: skill_unit,
        trace_id: draft_skill_class_unit.trace_id
      )

      # 移動元とドラフトデータ上での移動の準備
      draft_skill_class_2 = insert(:draft_skill_class, skill_panel_id: ctx.skill_panel.id)

      skill_class_2 =
        insert(:skill_class,
          skill_panel_id: ctx.skill_panel.id,
          trace_id: draft_skill_class_2.trace_id
        )

      {
        {draft_skill_unit_2, _draft_skill_category_2, draft_skill_2},
        {skill_unit_2, _skill_category_2, skill_2}
      } = create_skill_with_draft()

      draft_skill_class_unit_2 =
        insert(:draft_skill_class_unit,
          draft_skill_class: draft_skill_class_2,
          draft_skill_unit: draft_skill_unit_2
        )

      insert(:skill_class_unit,
        skill_class: skill_class_2,
        skill_unit: skill_unit_2,
        trace_id: draft_skill_class_unit_2.trace_id
      )

      #   ドラフト上での移動処理相当のupdate
      Repo.update(
        Ecto.Changeset.change(draft_skill_2, draft_skill_category_id: draft_skill_category.id)
      )

      # 処理前のスコア準備
      user = insert(:user)
      skill_panel = Repo.get(SkillPanel, ctx.skill_panel.id)
      insert(:user_skill_panel, skill_panel: skill_panel, user: user)
      insert(:skill_score, skill: skill, user: user, score: :low)
      insert(:skill_score, skill: skill_2, user: user, score: :high)
      insert(:skill_class_score, skill_class: skill_class, user: user)

      skill_unit_score =
        insert(:skill_unit_score, skill_unit: skill_unit, user: user, percentage: 0)

      Release.commit(ctx.skill_panel)

      # 処理後データ状況（スキルユニットスコア）の確認
      skill_unit_score = Repo.get_by(SkillUnitScore, id: skill_unit_score.id)
      assert skill_unit_score.percentage == 50
    end
  end
end
