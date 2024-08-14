defmodule Bright.Batches.UpdateCareerFieldScoresTest do
  use Bright.DataCase

  alias Bright.Batches.UpdateCareerFieldScores
  alias Bright.SkillScores.CareerFieldScore

  # データ用意／スキル構造
  # - 3つのキャリアフィールド
  # - 4つのジョブ 1つは全キャリアフィールド共通
  # - 5つのスキルパネル 1つは全ジョブ共通
  # - 5つのスキルクラス 5つのスキルパネルがそれぞれ1つ保持（本来1~3であるが割愛）
  # - 6つのスキルユニット 1つは全スキルクラス共通
  # - 6つのスキル 6つのスキルユニットがそれぞれ1つ保持
  # - 共通利用のデータは頭につけている

  setup do
    # career_fields
    career_fields = insert_list(3, :career_field)

    # jobs
    own_jobs =
      Enum.map(career_fields, fn career_field ->
        insert(
          :job,
          career_fields: [career_field],
          career_field_jobs: [build(:career_field_job, career_field: career_field)]
        )
      end)

    shared_job = insert(:job, career_fields: career_fields)
    Enum.each(career_fields, &insert(:career_field_job, career_field: &1, job: shared_job))

    jobs = [shared_job] ++ own_jobs

    # skill_panels
    own_skill_panels =
      Enum.map(jobs, fn job ->
        insert(
          :skill_panel,
          jobs: [job],
          job_skill_panels: [build(:job_skill_panel, job: job)]
        )
      end)

    shared_skill_panel = insert(:skill_panel, jobs: jobs)
    Enum.each(jobs, &insert(:job_skill_panel, job: &1, skill_panel: shared_skill_panel))

    skill_panels = [shared_skill_panel] ++ own_skill_panels

    %{career_fields: career_fields}

    # skill_classes
    skill_classes = Enum.map(skill_panels, &insert(:skill_class, skill_panel: &1))

    # skill_units
    own_skill_units =
      Enum.map(skill_classes, fn skill_class ->
        insert(
          :skill_unit,
          skill_classes: [skill_class],
          skill_class_units: [build(:skill_class_unit, skill_class: skill_class)]
        )
      end)

    shared_skill_unit = insert(:skill_unit, skill_classes: skill_classes)

    Enum.each(
      skill_classes,
      &insert(:skill_class_unit, skill_class: &1, skill_unit: shared_skill_unit)
    )

    skill_units = [shared_skill_unit] ++ own_skill_units

    # skills
    skills =
      Enum.map(skill_units, fn skill_unit ->
        [%{skills: [skill]}] = insert_skill_categories_and_skills(skill_unit, [1])
        skill
      end)

    %{
      career_fields: career_fields,
      jobs: jobs,
      skill_panels: skill_panels,
      skill_units: skill_units,
      skills: skills
    }
  end

  describe "call/0" do
    setup do
      user = insert(:user)
      %{user: user}
    end

    test "does not create career_field_scores, case skill_scores are empty", %{user: user} do
      UpdateCareerFieldScores.call()
      assert [] = Repo.preload(user, :career_field_scores).career_field_scores
    end

    test "create career_field_scores, case user has all high skill", %{
      user: user,
      skill_panels: skill_panels,
      skills: skills
    } do
      Enum.each(skills, &insert(:skill_score, skill: &1, user: user, score: :high))
      Enum.each(skill_panels, &insert(:user_skill_panel, skill_panel: &1, user: user))

      UpdateCareerFieldScores.call()

      # 全てのスコアが1.0であること
      career_field_scores = Repo.preload(user, :career_field_scores).career_field_scores
      assert 3 == Enum.count(career_field_scores)

      Enum.each(career_field_scores, fn career_field_score ->
        assert 4 == career_field_score.high_skills_count
        assert 100.0 == career_field_score.percentage
      end)
    end

    test "create career_field_scores, case user has one high skill", %{
      user: user,
      career_fields: career_fields,
      skill_panels: skill_panels,
      skills: skills
    } do
      skill_panel = List.last(skill_panels)
      skill = List.last(skills)
      insert(:user_skill_panel, skill_panel: skill_panel, user: user)
      insert(:skill_score, skill: skill, user: user, score: :high)

      UpdateCareerFieldScores.call()

      [
        unfocus_career_field_1,
        unfocus_career_field_2,
        career_field
      ] = career_fields

      # 取得済みのスキルパネルにはスキルが2つがあり習得は1なので50%
      assert %{
               high_skills_count: 1,
               percentage: 50.0
             } = Repo.get_by(CareerFieldScore, user_id: user.id, career_field_id: career_field.id)

      # その他キャリアフィールドは現状取得していない、かつ該当スキルではないのでゼロ
      assert %{
               high_skills_count: 0,
               percentage: +0.0
             } =
               Repo.get_by(CareerFieldScore,
                 user_id: user.id,
                 career_field_id: unfocus_career_field_1.id
               )

      assert %{
               high_skills_count: 0,
               percentage: +0.0
             } =
               Repo.get_by(CareerFieldScore,
                 user_id: user.id,
                 career_field_id: unfocus_career_field_2.id
               )
    end

    test "create career_field_scores, case user has one high shared skill", %{
      user: user,
      career_fields: career_fields,
      skill_panels: skill_panels,
      skills: [shared_skill | _]
    } do
      skill_panel = List.last(skill_panels)
      insert(:user_skill_panel, skill_panel: skill_panel, user: user)
      insert(:skill_score, skill: shared_skill, user: user, score: :high)

      UpdateCareerFieldScores.call()

      [
        unfocus_career_field_1,
        unfocus_career_field_2,
        career_field
      ] = career_fields

      # 取得済みのスキルパネルにはスキルが2つがあり習得は1なので50%
      assert %{
               high_skills_count: 1,
               percentage: 50.0
             } = Repo.get_by(CareerFieldScore, user_id: user.id, career_field_id: career_field.id)

      # その他キャリアフィールドは現状取得していない、かつ該当スキルのため習得率が入る
      # NOTE: ここが現状で母数が小さく100%になるため対応が必要と思われる
      assert %{
               high_skills_count: 1,
               percentage: 100.0
             } =
               Repo.get_by(CareerFieldScore,
                 user_id: user.id,
                 career_field_id: unfocus_career_field_1.id
               )

      assert %{
               high_skills_count: 1,
               percentage: 100.0
             } =
               Repo.get_by(CareerFieldScore,
                 user_id: user.id,
                 career_field_id: unfocus_career_field_2.id
               )
    end

    test "updates career_field_scores", %{
      user: user,
      career_fields: [career_field | _],
      skill_panels: [skill_panel | _],
      skills: [shared_skill | _]
    } do
      insert(:user_skill_panel, skill_panel: skill_panel, user: user)
      insert(:skill_score, skill: shared_skill, user: user, score: :low)

      # でたらめなデータを作成し、更新で是正されるかを確認
      career_field_score =
        insert(:career_field_score,
          user: user,
          career_field: career_field,
          percentage: 100.0,
          high_skills_count: 10
        )

      UpdateCareerFieldScores.call()

      career_field_score = Repo.get(CareerFieldScore, career_field_score.id)
      assert career_field_score.percentage == 0
      assert career_field_score.high_skills_count == 0
    end

    test "no error occured if job_skill_panels is empty", %{
      user: user,
      jobs: [job | _],
      skill_panels: [skill_panel | _],
      skills: [shared_skill | _]
    } do
      insert(:user_skill_panel, skill_panel: skill_panel, user: user)
      insert(:skill_score, skill: shared_skill, user: user, score: :low)
      Repo.delete_all(Ecto.assoc(job, :job_skill_panels))

      UpdateCareerFieldScores.call()
    end
  end
end
