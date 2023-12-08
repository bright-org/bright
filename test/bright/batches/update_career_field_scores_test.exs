defmodule Bright.Batches.UpdateCareerFieldScoresTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.Batches.UpdateCareerFieldScores
  alias Bright.SkillScores.CareerFieldScore

  # データ用意／キャリアフィールド
  setup do
    career_fields = insert_pair(:career_field)
    %{career_fields: career_fields}
  end

  # データ用意／ジョブ
  setup %{career_fields: career_fields} do
    jobs =
      Enum.flat_map(career_fields, fn career_field ->
        insert_pair(
          :job,
          career_fields: [career_field],
          career_field_jobs: [build(:career_field_job, career_field: career_field)]
        )
      end)

    %{jobs: jobs}
  end

  # データ用意／スキルパネル
  setup %{jobs: jobs} do
    skill_panels =
      Enum.flat_map(jobs, fn job ->
        insert_pair(
          :skill_panel,
          jobs: [job],
          job_skill_panels: [build(:job_skill_panel, job: job)]
        )
      end)

    %{skill_panels: skill_panels}
  end

  # データ用意／スキルユニット
  setup %{skill_panels: skill_panels} do
    skill_units =
      Enum.flat_map(skill_panels, fn skill_panel ->
        skill_class = insert(:skill_class, skill_panel: skill_panel)

        insert_pair(
          :skill_unit,
          skill_classes: [skill_class],
          skill_class_units: [build(:skill_class_unit, skill_class: skill_class)]
        )
      end)

    %{skill_units: skill_units}
  end

  # データ用意／スキル
  setup %{skill_units: skill_units} do
    skills =
      Enum.flat_map(skill_units, fn skill_unit ->
        [%{skills: skills_a}, %{skills: skills_b}] =
          insert_skill_categories_and_skills(skill_unit, [2, 2])

        skills_a ++ skills_b
      end)

    %{skills: skills}
  end

  describe "call/0" do
    setup do
      user = insert(:user)
      %{user: user}
    end

    test "not creates career_field_scores, case skill_scores are empty", %{user: user} do
      UpdateCareerFieldScores.call()
      assert [] = Repo.preload(user, :career_field_scores).career_field_scores
    end

    test "creates career_field_scores", %{
      user: user,
      career_fields: [career_field_1, career_field_2],
      skills: skills
    } do
      # スキルスコア用意
      [
        # 0, 1はcareer_field_1に属する
        {Enum.at(skills, 0), :high},
        {Enum.at(skills, 1), :high},
        # -1, -2はcareer_field_2に属する
        {Enum.at(skills, -1), :high},
        {Enum.at(skills, -2), :middle}
      ]
      |> Enum.each(fn {skill, score} ->
        insert(:skill_score, user: user, skill: skill, score: score)
      end)

      # キャリアフィールドのpercentage（相対的な取得割合）の母数
      sum_high_skills_count = 3

      UpdateCareerFieldScores.call()

      career_field_score_1 =
        Repo.get_by(CareerFieldScore, user_id: user.id, career_field_id: career_field_1.id)

      career_field_score_2 =
        Repo.get_by(CareerFieldScore, user_id: user.id, career_field_id: career_field_2.id)

      assert career_field_score_1.high_skills_count == 2
      assert career_field_score_1.percentage == 100 * (2 / sum_high_skills_count)

      assert career_field_score_2.high_skills_count == 1
      assert career_field_score_2.percentage == 100 * (1 / sum_high_skills_count)
    end

    test "updates career_field_scores", %{
      user: user,
      career_fields: [career_field, _],
      skills: [skill | _]
    } do
      # でたらめなデータを作成し、更新で是正されるかを確認
      career_field_score =
        insert(:career_field_score,
          user: user,
          career_field: career_field,
          percentage: 100.0,
          high_skills_count: 100
        )

      # スキルスコア用意
      insert(:skill_score, user: user, skill: skill, score: :high)

      UpdateCareerFieldScores.call()

      career_field_score = Repo.get(CareerFieldScore, career_field_score.id)
      assert career_field_score.high_skills_count == 1
      assert career_field_score.percentage == 100 * (1 / 1)
    end

    test "multiple users must be covered", %{
      user: user_1,
      career_fields: [career_field_1, career_field_2],
      skills: skills
    } do
      # キャリアフィールドスコア [1, 2] に対して、
      # user_1 [1/1, 0]
      # user_2 [0, 1/1]
      # がupsertにより期待結果となるようなデータを準備
      user_2 = insert(:user)
      skill_1 = Enum.at(skills, 0)
      skill_2 = Enum.at(skills, -1)
      insert(:skill_score, user: user_1, skill: skill_1, score: :high)
      insert(:skill_score, user: user_2, skill: skill_2, score: :high)

      insert(:career_field_score,
        user: user_1,
        career_field: career_field_2,
        percentage: 100.0,
        high_skills_count: 100
      )

      insert(:career_field_score,
        user: user_2,
        career_field: career_field_1,
        percentage: 100.0,
        high_skills_count: 100
      )

      UpdateCareerFieldScores.call()

      percentage = 100 * (1 / 1)

      assert %{high_skills_count: 1, percentage: ^percentage} =
               Repo.get_by(CareerFieldScore,
                 user_id: user_1.id,
                 career_field_id: career_field_1.id
               )

      assert %{high_skills_count: 0, percentage: 0.0} =
               Repo.get_by(CareerFieldScore,
                 user_id: user_1.id,
                 career_field_id: career_field_2.id
               )

      assert %{high_skills_count: 0, percentage: 0.0} =
               Repo.get_by(CareerFieldScore,
                 user_id: user_2.id,
                 career_field_id: career_field_1.id
               )

      assert %{high_skills_count: 1, percentage: ^percentage} =
               Repo.get_by(CareerFieldScore,
                 user_id: user_2.id,
                 career_field_id: career_field_2.id
               )
    end

    test "no error occured if jobsskill_panels is empty", %{jobs: [job | _]} do
      Repo.delete_all(Ecto.assoc(job, :job_skill_panels))
      UpdateCareerFieldScores.call()
    end
  end
end
