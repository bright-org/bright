defmodule Bright.Batches.UpdateSkillPanelsTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.Batches.UpdateSkillPanels

  describe "call/2" do
    alias Bright.Repo

    alias Bright.SkillUnits.{SkillUnit, SkillClassUnit}
    alias Bright.SkillPanels.SkillClass
    alias Bright.SkillScores.{SkillUnitScore, SkillScore, SkillClassScore, CareerFieldScore}
    alias Bright.SkillEvidences.SkillEvidence
    alias Bright.SkillExams.SkillExam
    alias Bright.SkillReferences.SkillReference

    alias Bright.HistoricalSkillUnits.{HistoricalSkillUnit, HistoricalSkillClassUnit}
    alias Bright.HistoricalSkillPanels.HistoricalSkillClass

    alias Bright.HistoricalSkillScores.{
      HistoricalSkillUnitScore,
      HistoricalSkillScore,
      HistoricalSkillClassScore,
      HistoricalCareerFieldScore
    }

    @locked_date Date.utc_today()
    @before_locked_date Date.add(@locked_date, -30)

    # 運営下書きスキルユニットのデータを準備
    setup do
      draft_skill_units =
        insert_list(3, :draft_skill_unit)
        |> Enum.map(fn draft_skill_unit ->
          insert_list(3, :draft_skill_category, draft_skill_unit: draft_skill_unit)
          |> Enum.map(fn draft_skill_category ->
            insert_list(3, :draft_skill, draft_skill_category: draft_skill_category)
          end)

          draft_skill_unit
        end)
        |> Repo.preload(draft_skill_categories: :draft_skills)

      %{draft_skill_units: draft_skill_units}
    end

    # 運営下書きスキルクラスのデータを準備
    setup %{draft_skill_units: draft_skill_units} do
      draft_skill_panel = insert(:draft_skill_panel)

      draft_skill_classes = [
        insert(:draft_skill_class, skill_panel: draft_skill_panel, class: 1),
        insert(:draft_skill_class, skill_panel: draft_skill_panel, class: 2),
        insert(:draft_skill_class, skill_panel: draft_skill_panel, class: 3)
      ]

      draft_skill_class_units = [
        insert(:draft_skill_class_unit,
          draft_skill_class: Enum.at(draft_skill_classes, 0),
          draft_skill_unit: Enum.at(draft_skill_units, 0)
        ),
        insert(:draft_skill_class_unit,
          draft_skill_class: Enum.at(draft_skill_classes, 0),
          draft_skill_unit: Enum.at(draft_skill_units, 1)
        ),
        insert(:draft_skill_class_unit,
          draft_skill_class: Enum.at(draft_skill_classes, 1),
          draft_skill_unit: Enum.at(draft_skill_units, 1)
        ),
        insert(:draft_skill_class_unit,
          draft_skill_class: Enum.at(draft_skill_classes, 2),
          draft_skill_unit: Enum.at(draft_skill_units, 2)
        )
      ]

      %{
        draft_skill_classes: draft_skill_classes,
        draft_skill_class_units: draft_skill_class_units
      }
    end

    # 公開スキルユニットのデータを準備
    setup %{draft_skill_units: draft_skill_units} do
      skill_units =
        draft_skill_units
        |> Enum.take(2)
        |> Enum.map(fn draft_skill_unit ->
          skill_unit =
            insert(:skill_unit,
              locked_date: @before_locked_date,
              trace_id: draft_skill_unit.trace_id
            )

          draft_skill_unit.draft_skill_categories
          |> Enum.take(2)
          |> Enum.map(fn draft_skill_category ->
            skill_category =
              insert(:skill_category,
                skill_unit: skill_unit,
                trace_id: draft_skill_category.trace_id
              )

            draft_skill_category.draft_skills
            |> Enum.take(2)
            |> Enum.map(fn draft_skill ->
              insert(:skill, skill_category: skill_category, trace_id: draft_skill.trace_id)
            end)
          end)

          skill_unit
        end)
        |> Repo.preload(skill_categories: :skills)

      %{skill_units: skill_units}
    end

    # 公開スキルクラスのデータを準備
    setup %{
      draft_skill_classes: draft_skill_classes,
      draft_skill_class_units: draft_skill_class_units,
      skill_units: skill_units
    } do
      skill_classes =
        draft_skill_classes
        |> Enum.take(2)
        |> Enum.map(fn draft_skill_class ->
          insert(:skill_class,
            skill_panel_id: draft_skill_class.skill_panel_id,
            locked_date: @before_locked_date,
            trace_id: draft_skill_class.trace_id,
            class: draft_skill_class.class
          )
        end)

      skill_class_units = [
        insert(:skill_class_unit,
          skill_class: Enum.at(skill_classes, 0),
          skill_unit: Enum.at(skill_units, 0),
          trace_id: Enum.at(draft_skill_class_units, 0).trace_id
        ),
        insert(:skill_class_unit,
          skill_class: Enum.at(skill_classes, 0),
          skill_unit: Enum.at(skill_units, 1),
          trace_id: Enum.at(draft_skill_class_units, 1).trace_id
        ),
        insert(:skill_class_unit,
          skill_class: Enum.at(skill_classes, 1),
          skill_unit: Enum.at(skill_units, 1),
          trace_id: Enum.at(draft_skill_class_units, 2).trace_id
        )
      ]

      %{skill_classes: skill_classes, skill_class_units: skill_class_units}
    end

    # 公開スキルスコアのデータを準備
    setup %{skill_units: skill_units, skill_classes: skill_classes} do
      [user1, user2] = insert_pair(:user)

      skill_unit_scores =
        Enum.flat_map(skill_units, fn skill_unit ->
          [
            insert(:skill_unit_score, skill_unit: skill_unit, user: user1, percentage: 1.0),
            insert(:skill_unit_score, skill_unit: skill_unit, user: user2, percentage: 1.0)
          ]
        end)

      skill_scores =
        Enum.flat_map(skill_units, fn skill_unit ->
          Enum.flat_map(skill_unit.skill_categories, fn skill_category ->
            Enum.flat_map(skill_category.skills, fn skill ->
              [
                insert(:skill_score, skill: skill, user: user1, score: :middle),
                insert(:skill_score, skill: skill, user: user2, score: :middle)
              ]
            end)
          end)
        end)

      skill_class_scores =
        Enum.flat_map(skill_classes, fn skill_class ->
          [
            insert(:skill_class_score, skill_class: skill_class, user: user1, percentage: 1.0),
            insert(:skill_class_score, skill_class: skill_class, user: user2, percentage: 1.0)
          ]
        end)

      career_field_scores = [
        insert(:career_field_score, user: user1),
        insert(:career_field_score, user: user2)
      ]

      %{
        skill_unit_scores: skill_unit_scores,
        skill_scores: skill_scores,
        skill_class_scores: skill_class_scores,
        career_field_scores: career_field_scores
      }
    end

    # エビデンス・試験・教材のデータを準備
    setup %{skill_units: skill_units} do
      skills =
        Enum.flat_map(skill_units, fn skill_unit ->
          Enum.flat_map(skill_unit.skill_categories, fn skill_category ->
            skill_category.skills
          end)
        end)

      skill_evidences =
        Enum.map(skills, fn skill ->
          skill_evidence = insert(:skill_evidence, skill: skill, user: insert(:user))

          insert_pair(:skill_evidence_post,
            skill_evidence: skill_evidence,
            user: skill_evidence.user
          )

          skill_evidence
        end)

      skill_exams = Enum.map(skills, fn skill -> insert(:skill_exam, skill: skill) end)
      skill_references = Enum.map(skills, fn skill -> insert(:skill_reference, skill: skill) end)

      %{
        skill_evidences: skill_evidences,
        skill_exams: skill_exams,
        skill_references: skill_references
      }
    end

    test "updates skill panels when published data are less than draft data", %{
      draft_skill_units: draft_skill_units,
      draft_skill_classes: draft_skill_classes,
      draft_skill_class_units: draft_skill_class_units,
      skill_units: skill_units,
      skill_classes: skill_classes,
      skill_class_units: skill_class_units,
      skill_unit_scores: skill_unit_scores,
      skill_scores: skill_scores,
      skill_class_scores: skill_class_scores,
      career_field_scores: career_field_scores,
      skill_evidences: skill_evidences,
      skill_exams: skill_exams,
      skill_references: skill_references
    } do
      UpdateSkillPanels.call(@locked_date)

      # スキルユニットの公開データ生成を確認
      published_skill_units = Repo.all(SkillUnit)
      assert length(published_skill_units) == length(draft_skill_units)

      Enum.each(draft_skill_units, fn draft_skill_unit ->
        published_skill_unit =
          Enum.find(published_skill_units, fn %{trace_id: trace_id} ->
            trace_id == draft_skill_unit.trace_id
          end)

        assert published_skill_unit.locked_date == @locked_date
        assert published_skill_unit.name == draft_skill_unit.name

        # カテゴリの公開データ生成を確認
        draft_skill_categories = draft_skill_unit.draft_skill_categories

        published_skill_categories = Repo.all(Ecto.assoc(published_skill_unit, :skill_categories))

        assert length(published_skill_categories) == length(draft_skill_categories)

        Enum.each(draft_skill_categories, fn draft_skill_category ->
          published_skill_category =
            Enum.find(published_skill_categories, fn %{trace_id: trace_id} ->
              trace_id == draft_skill_category.trace_id
            end)

          assert published_skill_category.skill_unit_id == published_skill_unit.id
          assert published_skill_category.name == draft_skill_category.name
          assert published_skill_category.position == draft_skill_category.position

          # スキルの公開データ生成を確認
          draft_skills = draft_skill_category.draft_skills
          published_skills = Repo.all(Ecto.assoc(published_skill_category, :skills))
          assert length(published_skills) == length(draft_skills)

          Enum.each(draft_skills, fn draft_skill ->
            published_skill =
              Enum.find(published_skills, fn %{trace_id: trace_id} ->
                trace_id == draft_skill.trace_id
              end)

            assert published_skill.skill_category_id == published_skill_category.id
            assert published_skill.name == draft_skill.name
            assert published_skill.position == draft_skill.position
          end)
        end)
      end)

      # スキルクラスの公開データ生成を確認
      published_skill_classes = Repo.all(SkillClass)
      assert length(published_skill_classes) == length(draft_skill_classes)

      Enum.each(draft_skill_classes, fn draft_skill_class ->
        published_skill_class =
          Enum.find(published_skill_classes, fn %{trace_id: trace_id} ->
            trace_id == draft_skill_class.trace_id
          end)

        assert published_skill_class.skill_panel_id == draft_skill_class.skill_panel_id
        assert published_skill_class.locked_date == @locked_date
        assert published_skill_class.name == draft_skill_class.name
        assert published_skill_class.class == draft_skill_class.class
      end)

      # スキルユニットとスキルクラスの中間テーブルの公開データ生成を確認
      published_skill_class_units = Repo.all(SkillClassUnit)
      assert length(published_skill_class_units) == length(draft_skill_class_units)

      Enum.each(draft_skill_class_units, fn draft_skill_class_unit ->
        published_skill_class_unit =
          Enum.find(published_skill_class_units, fn %{trace_id: trace_id} ->
            trace_id == draft_skill_class_unit.trace_id
          end)

        published_skill_unit =
          Enum.find(published_skill_units, fn %{trace_id: trace_id} ->
            trace_id == draft_skill_class_unit.draft_skill_unit.trace_id
          end)

        published_skill_class =
          Enum.find(published_skill_classes, fn %{trace_id: trace_id} ->
            trace_id == draft_skill_class_unit.draft_skill_class.trace_id
          end)

        assert published_skill_class_unit.skill_unit_id == published_skill_unit.id
        assert published_skill_class_unit.skill_class_id == published_skill_class.id
        assert published_skill_class_unit.position == draft_skill_class_unit.position
      end)

      # スキルユニット単位の集計の公開データ生成を確認
      published_skill_unit_scores = Repo.all(SkillUnitScore) |> Repo.preload(:skill_unit)
      assert length(published_skill_unit_scores) == length(skill_unit_scores)

      Enum.each(skill_unit_scores, fn skill_unit_score ->
        published_skill_unit_score =
          Enum.find(published_skill_unit_scores, fn %{
                                                      user_id: user_id,
                                                      skill_unit: %{trace_id: trace_id}
                                                    } ->
            user_id == skill_unit_score.user_id &&
              trace_id == skill_unit_score.skill_unit.trace_id
          end)

        # 再計算を確認
        assert published_skill_unit_score.percentage != skill_unit_score.percentage
      end)

      # スキル単位のスコアの公開データ生成を確認
      published_skill_scores = Repo.all(SkillScore) |> Repo.preload(:skill)
      assert length(published_skill_scores) == length(skill_scores)

      Enum.each(skill_scores, fn skill_score ->
        published_skill_score =
          Enum.find(published_skill_scores, fn %{user_id: user_id, skill: %{trace_id: trace_id}} ->
            user_id == skill_score.user_id && trace_id == skill_score.skill.trace_id
          end)

        assert published_skill_score.score == skill_score.score
        assert published_skill_score.exam_progress == skill_score.exam_progress
        assert published_skill_score.reference_read == skill_score.reference_read
        assert published_skill_score.evidence_filled == skill_score.evidence_filled
      end)

      # スキルクラス単位の集計の公開データ生成を確認
      published_skill_class_scores = Repo.all(SkillClassScore) |> Repo.preload(:skill_class)
      assert length(published_skill_class_scores) == length(skill_class_scores)

      Enum.each(skill_class_scores, fn skill_class_score ->
        published_skill_class_score =
          Enum.find(published_skill_class_scores, fn %{
                                                       user_id: user_id,
                                                       skill_class: %{trace_id: trace_id}
                                                     } ->
            user_id == skill_class_score.user_id &&
              trace_id == skill_class_score.skill_class.trace_id
          end)

        # 再計算を確認
        assert published_skill_class_score.percentage != skill_class_score.percentage
      end)

      # キャリアフィールド単位の集計の公開データ生成を確認
      published_career_field_scores = Repo.all(CareerFieldScore)
      assert length(published_career_field_scores) == length(career_field_scores)

      Enum.each(career_field_scores, fn career_field_score ->
        published_career_field_score =
          Enum.find(published_career_field_scores, fn %{
                                                        user_id: user_id,
                                                        career_field_id: career_field_id
                                                      } ->
            user_id == career_field_score.user_id &&
              career_field_id == career_field_score.career_field_id
          end)

        assert published_career_field_score.percentage == career_field_score.percentage

        assert published_career_field_score.high_skills_count ==
                 career_field_score.high_skills_count
      end)

      # エビデンスのデータ更新を確認
      updated_skill_evidences = Repo.all(SkillEvidence) |> Repo.preload(:skill)
      assert length(updated_skill_evidences) == length(skill_evidences)

      Enum.each(skill_evidences, fn skill_evidence ->
        updated_skill_evidence =
          Enum.find(updated_skill_evidences, fn %{id: id} ->
            id == skill_evidence.id
          end)

        assert updated_skill_evidence.skill.trace_id == skill_evidence.skill.trace_id
      end)

      # 試験のデータ更新を確認
      updated_skill_exams = Repo.all(SkillExam) |> Repo.preload(:skill)
      assert length(updated_skill_exams) == length(skill_exams)

      Enum.each(skill_exams, fn skill_exam ->
        updated_skill_exam =
          Enum.find(updated_skill_exams, fn %{id: id} ->
            id == skill_exam.id
          end)

        assert updated_skill_exam.skill.trace_id == skill_exam.skill.trace_id
      end)

      # 教材のデータ更新を確認
      updated_skill_references = Repo.all(SkillReference) |> Repo.preload(:skill)
      assert length(updated_skill_references) == length(skill_references)

      Enum.each(skill_references, fn skill_reference ->
        updated_skill_reference =
          Enum.find(updated_skill_references, fn %{id: id} ->
            id == skill_reference.id
          end)

        assert updated_skill_reference.skill.trace_id == skill_reference.skill.trace_id
      end)

      # スキルユニットの履歴データ生成を確認
      historical_skill_units = Repo.all(HistoricalSkillUnit)
      assert length(historical_skill_units) == length(skill_units)

      Enum.each(skill_units, fn skill_unit ->
        historical_skill_unit =
          Enum.find(historical_skill_units, fn %{trace_id: trace_id} ->
            trace_id == skill_unit.trace_id
          end)

        assert historical_skill_unit.locked_date == skill_unit.locked_date
        assert historical_skill_unit.name == skill_unit.name

        # カテゴリの履歴データ生成を確認
        skill_categories = skill_unit.skill_categories

        historical_skill_categories =
          Repo.all(Ecto.assoc(historical_skill_unit, :historical_skill_categories))

        assert length(historical_skill_categories) == length(skill_categories)

        Enum.each(skill_categories, fn skill_category ->
          historical_skill_category =
            Enum.find(historical_skill_categories, fn %{trace_id: trace_id} ->
              trace_id == skill_category.trace_id
            end)

          assert historical_skill_category.historical_skill_unit_id == historical_skill_unit.id
          assert historical_skill_category.name == skill_category.name
          assert historical_skill_category.position == skill_category.position

          # スキルの履歴データ生成を確認
          skills = skill_category.skills
          historical_skills = Repo.all(Ecto.assoc(historical_skill_category, :historical_skills))
          assert length(historical_skills) == length(skills)

          Enum.each(skills, fn skill ->
            historical_skill =
              Enum.find(historical_skills, fn %{trace_id: trace_id} ->
                trace_id == skill.trace_id
              end)

            assert historical_skill.historical_skill_category_id == historical_skill_category.id
            assert historical_skill.name == skill.name
            assert historical_skill.position == skill.position
          end)
        end)
      end)

      # スキルクラスの履歴データ生成を確認
      historical_skill_classes = Repo.all(HistoricalSkillClass)
      assert length(historical_skill_classes) == length(skill_classes)

      Enum.each(skill_classes, fn skill_class ->
        historical_skill_class =
          Enum.find(historical_skill_classes, fn %{trace_id: trace_id} ->
            trace_id == skill_class.trace_id
          end)

        assert historical_skill_class.skill_panel_id == skill_class.skill_panel_id
        assert historical_skill_class.locked_date == skill_class.locked_date
        assert historical_skill_class.name == skill_class.name
        assert historical_skill_class.class == skill_class.class
      end)

      # スキルユニットとスキルクラスの中間テーブルの履歴データ生成を確認
      historical_skill_class_units = Repo.all(HistoricalSkillClassUnit)
      assert length(historical_skill_class_units) == length(skill_class_units)

      Enum.each(skill_class_units, fn skill_class_unit ->
        historical_skill_class_unit =
          Enum.find(historical_skill_class_units, fn %{trace_id: trace_id} ->
            trace_id == skill_class_unit.trace_id
          end)

        historical_skill_unit =
          Enum.find(historical_skill_units, fn %{trace_id: trace_id} ->
            trace_id == skill_class_unit.skill_unit.trace_id
          end)

        historical_skill_class =
          Enum.find(historical_skill_classes, fn %{trace_id: trace_id} ->
            trace_id == skill_class_unit.skill_class.trace_id
          end)

        assert historical_skill_class_unit.historical_skill_unit_id == historical_skill_unit.id
        assert historical_skill_class_unit.historical_skill_class_id == historical_skill_class.id
        assert historical_skill_class_unit.position == skill_class_unit.position
      end)

      # スキルユニット単位の集計の履歴データ生成を確認
      historical_skill_unit_scores =
        Repo.all(HistoricalSkillUnitScore) |> Repo.preload(:historical_skill_unit)

      assert length(historical_skill_unit_scores) == length(skill_unit_scores)

      Enum.each(skill_unit_scores, fn skill_unit_score ->
        historical_skill_unit_score =
          Enum.find(historical_skill_unit_scores, fn %{
                                                       user_id: user_id,
                                                       historical_skill_unit: %{
                                                         trace_id: trace_id
                                                       }
                                                     } ->
            user_id == skill_unit_score.user_id &&
              trace_id == skill_unit_score.skill_unit.trace_id
          end)

        assert historical_skill_unit_score.locked_date == @locked_date
        assert historical_skill_unit_score.percentage == skill_unit_score.percentage
      end)

      # スキル単位のスコアの履歴データ生成を確認
      historical_skill_scores = Repo.all(HistoricalSkillScore) |> Repo.preload(:historical_skill)
      assert length(historical_skill_scores) == length(skill_scores)

      Enum.each(skill_scores, fn skill_score ->
        historical_skill_score =
          Enum.find(historical_skill_scores, fn %{
                                                  user_id: user_id,
                                                  historical_skill: %{trace_id: trace_id}
                                                } ->
            user_id == skill_score.user_id && trace_id == skill_score.skill.trace_id
          end)

        assert historical_skill_score.score == skill_score.score
        assert historical_skill_score.exam_progress == skill_score.exam_progress
        assert historical_skill_score.reference_read == skill_score.reference_read
        assert historical_skill_score.evidence_filled == skill_score.evidence_filled
      end)

      # スキルクラス単位の集計の履歴データ生成を確認
      historical_skill_class_scores =
        Repo.all(HistoricalSkillClassScore) |> Repo.preload(:historical_skill_class)

      assert length(historical_skill_class_scores) == length(skill_class_scores)

      Enum.each(skill_class_scores, fn skill_class_score ->
        historical_skill_class_score =
          Enum.find(historical_skill_class_scores, fn %{
                                                        user_id: user_id,
                                                        historical_skill_class: %{
                                                          trace_id: trace_id
                                                        }
                                                      } ->
            user_id == skill_class_score.user_id &&
              trace_id == skill_class_score.skill_class.trace_id
          end)

        assert historical_skill_class_score.locked_date == @locked_date
        assert historical_skill_class_score.percentage == skill_class_score.percentage
      end)

      # キャリアフィールド単位の集計の履歴データ生成を確認
      historical_career_field_scores = Repo.all(HistoricalCareerFieldScore)
      assert length(historical_career_field_scores) == length(career_field_scores)

      Enum.each(career_field_scores, fn career_field_score ->
        historical_career_field_score =
          Enum.find(historical_career_field_scores, fn %{
                                                         user_id: user_id,
                                                         career_field_id: career_field_id
                                                       } ->
            user_id == career_field_score.user_id &&
              career_field_id == career_field_score.career_field_id
          end)

        assert historical_career_field_score.locked_date == @locked_date
        assert historical_career_field_score.percentage == career_field_score.percentage

        assert historical_career_field_score.high_skills_count ==
                 career_field_score.high_skills_count
      end)
    end

    test "updates skill panels when published data are more than draft data", %{
      draft_skill_units: draft_skill_units,
      draft_skill_classes: draft_skill_classes,
      draft_skill_class_units: draft_skill_class_units,
      skill_units: skill_units,
      skill_classes: skill_classes,
      skill_class_units: skill_class_units,
      skill_unit_scores: skill_unit_scores,
      skill_scores: skill_scores,
      skill_class_scores: skill_class_scores,
      career_field_scores: career_field_scores,
      skill_evidences: skill_evidences,
      skill_exams: skill_exams,
      skill_references: skill_references
    } do
      other_skill_units =
        insert_pair(:skill_unit, locked_date: @before_locked_date)
        |> Enum.map(fn skill_unit ->
          insert_pair(:skill_category, skill_unit: skill_unit)
          |> Enum.map(fn skill_category ->
            insert_pair(:skill, skill_category: skill_category)
          end)

          skill_unit
        end)
        |> Repo.preload(skill_categories: :skills)

      other_skill_classes = insert_pair(:skill_class, skill_panel: insert(:skill_panel))

      other_skill_class_units = [
        insert(:skill_class_unit,
          skill_class: Enum.at(other_skill_classes, 0),
          skill_unit: Enum.at(other_skill_units, 0)
        ),
        insert(:skill_class_unit,
          skill_class: Enum.at(other_skill_classes, 1),
          skill_unit: Enum.at(other_skill_units, 1)
        )
      ]

      other_skill_unit_scores =
        Enum.flat_map(other_skill_units, fn skill_unit ->
          insert_pair(:skill_unit_score, skill_unit: skill_unit)
        end)

      other_skill_scores =
        Enum.flat_map(other_skill_units, fn skill_unit ->
          Enum.flat_map(skill_unit.skill_categories, fn skill_category ->
            Enum.flat_map(skill_category.skills, fn skill ->
              insert_pair(:skill_score, skill: skill)
            end)
          end)
        end)

      other_skill_class_scores =
        Enum.flat_map(other_skill_classes, fn skill_class ->
          insert_pair(:skill_class_score, skill_class: skill_class)
        end)

      Enum.each(other_skill_units, fn skill_unit ->
        Enum.each(skill_unit.skill_categories, fn skill_category ->
          Enum.each(skill_category.skills, fn skill ->
            skill_evidence = insert(:skill_evidence, skill: skill, user: insert(:user))

            insert_pair(:skill_evidence_post,
              skill_evidence: skill_evidence,
              user: skill_evidence.user
            )

            insert(:skill_exam, skill: skill)
            insert(:skill_reference, skill: skill)
          end)
        end)
      end)

      UpdateSkillPanels.call(@locked_date)

      # スキルユニットの公開データ生成を確認
      published_skill_units = Repo.all(SkillUnit)
      assert length(published_skill_units) == length(draft_skill_units)

      Enum.each(draft_skill_units, fn draft_skill_unit ->
        published_skill_unit =
          Enum.find(published_skill_units, fn %{trace_id: trace_id} ->
            trace_id == draft_skill_unit.trace_id
          end)

        assert published_skill_unit.locked_date == @locked_date
        assert published_skill_unit.name == draft_skill_unit.name

        # カテゴリの公開データ生成を確認
        draft_skill_categories = draft_skill_unit.draft_skill_categories

        published_skill_categories = Repo.all(Ecto.assoc(published_skill_unit, :skill_categories))

        assert length(published_skill_categories) == length(draft_skill_categories)

        Enum.each(draft_skill_categories, fn draft_skill_category ->
          published_skill_category =
            Enum.find(published_skill_categories, fn %{trace_id: trace_id} ->
              trace_id == draft_skill_category.trace_id
            end)

          assert published_skill_category.skill_unit_id == published_skill_unit.id
          assert published_skill_category.name == draft_skill_category.name
          assert published_skill_category.position == draft_skill_category.position

          # スキルの公開データ生成を確認
          draft_skills = draft_skill_category.draft_skills
          published_skills = Repo.all(Ecto.assoc(published_skill_category, :skills))
          assert length(published_skills) == length(draft_skills)

          Enum.each(draft_skills, fn draft_skill ->
            published_skill =
              Enum.find(published_skills, fn %{trace_id: trace_id} ->
                trace_id == draft_skill.trace_id
              end)

            assert published_skill.skill_category_id == published_skill_category.id
            assert published_skill.name == draft_skill.name
            assert published_skill.position == draft_skill.position
          end)
        end)
      end)

      # スキルクラスの公開データ生成を確認
      published_skill_classes = Repo.all(SkillClass)
      assert length(published_skill_classes) == length(draft_skill_classes)

      Enum.each(draft_skill_classes, fn draft_skill_class ->
        published_skill_class =
          Enum.find(published_skill_classes, fn %{trace_id: trace_id} ->
            trace_id == draft_skill_class.trace_id
          end)

        assert published_skill_class.skill_panel_id == draft_skill_class.skill_panel_id
        assert published_skill_class.locked_date == @locked_date
        assert published_skill_class.name == draft_skill_class.name
        assert published_skill_class.class == draft_skill_class.class
      end)

      # スキルユニットとスキルクラスの中間テーブルの公開データ生成を確認
      published_skill_class_units = Repo.all(SkillClassUnit)
      assert length(published_skill_class_units) == length(draft_skill_class_units)

      Enum.each(draft_skill_class_units, fn draft_skill_class_unit ->
        published_skill_class_unit =
          Enum.find(published_skill_class_units, fn %{trace_id: trace_id} ->
            trace_id == draft_skill_class_unit.trace_id
          end)

        published_skill_unit =
          Enum.find(published_skill_units, fn %{trace_id: trace_id} ->
            trace_id == draft_skill_class_unit.draft_skill_unit.trace_id
          end)

        published_skill_class =
          Enum.find(published_skill_classes, fn %{trace_id: trace_id} ->
            trace_id == draft_skill_class_unit.draft_skill_class.trace_id
          end)

        assert published_skill_class_unit.skill_unit_id == published_skill_unit.id
        assert published_skill_class_unit.skill_class_id == published_skill_class.id
        assert published_skill_class_unit.position == draft_skill_class_unit.position
      end)

      # スキルユニット単位の集計の公開データ生成を確認
      published_skill_unit_scores = Repo.all(SkillUnitScore) |> Repo.preload(:skill_unit)
      assert length(published_skill_unit_scores) == length(skill_unit_scores)

      Enum.each(skill_unit_scores, fn skill_unit_score ->
        published_skill_unit_score =
          Enum.find(published_skill_unit_scores, fn %{
                                                      user_id: user_id,
                                                      skill_unit: %{trace_id: trace_id}
                                                    } ->
            user_id == skill_unit_score.user_id &&
              trace_id == skill_unit_score.skill_unit.trace_id
          end)

        # 再計算を確認
        assert published_skill_unit_score.percentage != skill_unit_score.percentage
      end)

      # スキル単位のスコアの公開データ生成を確認
      published_skill_scores = Repo.all(SkillScore) |> Repo.preload(:skill)
      assert length(published_skill_scores) == length(skill_scores)

      Enum.each(skill_scores, fn skill_score ->
        published_skill_score =
          Enum.find(published_skill_scores, fn %{user_id: user_id, skill: %{trace_id: trace_id}} ->
            user_id == skill_score.user_id && trace_id == skill_score.skill.trace_id
          end)

        assert published_skill_score.score == skill_score.score
        assert published_skill_score.exam_progress == skill_score.exam_progress
        assert published_skill_score.reference_read == skill_score.reference_read
        assert published_skill_score.evidence_filled == skill_score.evidence_filled
      end)

      # スキルクラス単位の集計の公開データ生成を確認
      published_skill_class_scores = Repo.all(SkillClassScore) |> Repo.preload(:skill_class)
      assert length(published_skill_class_scores) == length(skill_class_scores)

      Enum.each(skill_class_scores, fn skill_class_score ->
        published_skill_class_score =
          Enum.find(published_skill_class_scores, fn %{
                                                       user_id: user_id,
                                                       skill_class: %{trace_id: trace_id}
                                                     } ->
            user_id == skill_class_score.user_id &&
              trace_id == skill_class_score.skill_class.trace_id
          end)

        # 再計算を確認
        assert published_skill_class_score.percentage != skill_class_score.percentage
      end)

      # キャリアフィールド単位の集計の公開データ生成を確認
      published_career_field_scores = Repo.all(CareerFieldScore)
      assert length(published_career_field_scores) == length(career_field_scores)

      Enum.each(career_field_scores, fn career_field_score ->
        published_career_field_score =
          Enum.find(published_career_field_scores, fn %{
                                                        user_id: user_id,
                                                        career_field_id: career_field_id
                                                      } ->
            user_id == career_field_score.user_id &&
              career_field_id == career_field_score.career_field_id
          end)

        assert published_career_field_score.percentage == career_field_score.percentage

        assert published_career_field_score.high_skills_count ==
                 career_field_score.high_skills_count
      end)

      # エビデンスのデータ更新を確認
      updated_skill_evidences = Repo.all(SkillEvidence) |> Repo.preload(:skill)
      assert length(updated_skill_evidences) == length(skill_evidences)

      Enum.each(skill_evidences, fn skill_evidence ->
        updated_skill_evidence =
          Enum.find(updated_skill_evidences, fn %{id: id} ->
            id == skill_evidence.id
          end)

        assert updated_skill_evidence.skill.trace_id == skill_evidence.skill.trace_id
      end)

      # 試験のデータ更新を確認
      updated_skill_exams = Repo.all(SkillExam) |> Repo.preload(:skill)
      assert length(updated_skill_exams) == length(skill_exams)

      Enum.each(skill_exams, fn skill_exam ->
        updated_skill_exam =
          Enum.find(updated_skill_exams, fn %{id: id} ->
            id == skill_exam.id
          end)

        assert updated_skill_exam.skill.trace_id == skill_exam.skill.trace_id
      end)

      # 教材のデータ更新を確認
      updated_skill_references = Repo.all(SkillReference) |> Repo.preload(:skill)
      assert length(updated_skill_references) == length(skill_references)

      Enum.each(skill_references, fn skill_reference ->
        updated_skill_reference =
          Enum.find(updated_skill_references, fn %{id: id} ->
            id == skill_reference.id
          end)

        assert updated_skill_reference.skill.trace_id == skill_reference.skill.trace_id
      end)

      # スキルユニットの履歴データ生成を確認
      historical_skill_units = Repo.all(HistoricalSkillUnit)
      assert length(historical_skill_units) == length(skill_units) + length(other_skill_units)

      Enum.each(skill_units, fn skill_unit ->
        historical_skill_unit =
          Enum.find(historical_skill_units, fn %{trace_id: trace_id} ->
            trace_id == skill_unit.trace_id
          end)

        assert historical_skill_unit.locked_date == skill_unit.locked_date
        assert historical_skill_unit.name == skill_unit.name

        # カテゴリの履歴データ生成を確認
        skill_categories = skill_unit.skill_categories

        historical_skill_categories =
          Repo.all(Ecto.assoc(historical_skill_unit, :historical_skill_categories))

        assert length(historical_skill_categories) == length(skill_categories)

        Enum.each(skill_categories, fn skill_category ->
          historical_skill_category =
            Enum.find(historical_skill_categories, fn %{trace_id: trace_id} ->
              trace_id == skill_category.trace_id
            end)

          assert historical_skill_category.historical_skill_unit_id == historical_skill_unit.id
          assert historical_skill_category.name == skill_category.name
          assert historical_skill_category.position == skill_category.position

          # スキルの履歴データ生成を確認
          skills = skill_category.skills
          historical_skills = Repo.all(Ecto.assoc(historical_skill_category, :historical_skills))
          assert length(historical_skills) == length(skills)

          Enum.each(skills, fn skill ->
            historical_skill =
              Enum.find(historical_skills, fn %{trace_id: trace_id} ->
                trace_id == skill.trace_id
              end)

            assert historical_skill.historical_skill_category_id == historical_skill_category.id
            assert historical_skill.name == skill.name
            assert historical_skill.position == skill.position
          end)
        end)
      end)

      # スキルクラスの履歴データ生成を確認
      historical_skill_classes = Repo.all(HistoricalSkillClass)

      assert length(historical_skill_classes) ==
               length(skill_classes) + length(other_skill_classes)

      Enum.each(skill_classes, fn skill_class ->
        historical_skill_class =
          Enum.find(historical_skill_classes, fn %{trace_id: trace_id} ->
            trace_id == skill_class.trace_id
          end)

        assert historical_skill_class.skill_panel_id == skill_class.skill_panel_id
        assert historical_skill_class.locked_date == skill_class.locked_date
        assert historical_skill_class.name == skill_class.name
        assert historical_skill_class.class == skill_class.class
      end)

      # スキルユニットとスキルクラスの中間テーブルの履歴データ生成を確認
      historical_skill_class_units = Repo.all(HistoricalSkillClassUnit)

      assert length(historical_skill_class_units) ==
               length(skill_class_units) + length(other_skill_class_units)

      Enum.each(skill_class_units, fn skill_class_unit ->
        historical_skill_class_unit =
          Enum.find(historical_skill_class_units, fn %{trace_id: trace_id} ->
            trace_id == skill_class_unit.trace_id
          end)

        historical_skill_unit =
          Enum.find(historical_skill_units, fn %{trace_id: trace_id} ->
            trace_id == skill_class_unit.skill_unit.trace_id
          end)

        historical_skill_class =
          Enum.find(historical_skill_classes, fn %{trace_id: trace_id} ->
            trace_id == skill_class_unit.skill_class.trace_id
          end)

        assert historical_skill_class_unit.historical_skill_unit_id == historical_skill_unit.id
        assert historical_skill_class_unit.historical_skill_class_id == historical_skill_class.id
        assert historical_skill_class_unit.position == skill_class_unit.position
      end)

      # スキルユニット単位の集計の履歴データ生成を確認
      historical_skill_unit_scores =
        Repo.all(HistoricalSkillUnitScore) |> Repo.preload(:historical_skill_unit)

      assert length(historical_skill_unit_scores) ==
               length(skill_unit_scores) + length(other_skill_unit_scores)

      Enum.each(skill_unit_scores, fn skill_unit_score ->
        historical_skill_unit_score =
          Enum.find(historical_skill_unit_scores, fn %{
                                                       user_id: user_id,
                                                       historical_skill_unit: %{
                                                         trace_id: trace_id
                                                       }
                                                     } ->
            user_id == skill_unit_score.user_id &&
              trace_id == skill_unit_score.skill_unit.trace_id
          end)

        assert historical_skill_unit_score.locked_date == @locked_date
        assert historical_skill_unit_score.percentage == skill_unit_score.percentage
      end)

      # スキル単位のスコアの履歴データ生成を確認
      historical_skill_scores = Repo.all(HistoricalSkillScore) |> Repo.preload(:historical_skill)
      assert length(historical_skill_scores) == length(skill_scores) + length(other_skill_scores)

      Enum.each(skill_scores, fn skill_score ->
        historical_skill_score =
          Enum.find(historical_skill_scores, fn %{
                                                  user_id: user_id,
                                                  historical_skill: %{trace_id: trace_id}
                                                } ->
            user_id == skill_score.user_id && trace_id == skill_score.skill.trace_id
          end)

        assert historical_skill_score.score == skill_score.score
        assert historical_skill_score.exam_progress == skill_score.exam_progress
        assert historical_skill_score.reference_read == skill_score.reference_read
        assert historical_skill_score.evidence_filled == skill_score.evidence_filled
      end)

      # スキルクラス単位の集計の履歴データ生成を確認
      historical_skill_class_scores =
        Repo.all(HistoricalSkillClassScore) |> Repo.preload(:historical_skill_class)

      assert length(historical_skill_class_scores) ==
               length(skill_class_scores) + length(other_skill_class_scores)

      Enum.each(skill_class_scores, fn skill_class_score ->
        historical_skill_class_score =
          Enum.find(historical_skill_class_scores, fn %{
                                                        user_id: user_id,
                                                        historical_skill_class: %{
                                                          trace_id: trace_id
                                                        }
                                                      } ->
            user_id == skill_class_score.user_id &&
              trace_id == skill_class_score.skill_class.trace_id
          end)

        assert historical_skill_class_score.locked_date == @locked_date
        assert historical_skill_class_score.level == skill_class_score.level
        assert historical_skill_class_score.percentage == skill_class_score.percentage
      end)

      # キャリアフィールド単位の集計の履歴データ生成を確認
      historical_career_field_scores = Repo.all(HistoricalCareerFieldScore)
      assert length(historical_career_field_scores) == length(career_field_scores)

      Enum.each(career_field_scores, fn career_field_score ->
        historical_career_field_score =
          Enum.find(historical_career_field_scores, fn %{
                                                         user_id: user_id,
                                                         career_field_id: career_field_id
                                                       } ->
            user_id == career_field_score.user_id &&
              career_field_id == career_field_score.career_field_id
          end)

        assert historical_career_field_score.locked_date == @locked_date
        assert historical_career_field_score.percentage == career_field_score.percentage

        assert historical_career_field_score.high_skills_count ==
                 career_field_score.high_skills_count
      end)
    end

    test "doesn't update skill panels when dry_run is true", %{
      skill_units: skill_units,
      skill_classes: skill_classes,
      skill_class_units: skill_class_units,
      skill_unit_scores: skill_unit_scores,
      skill_scores: skill_scores,
      skill_class_scores: skill_class_scores,
      career_field_scores: career_field_scores,
      skill_evidences: skill_evidences,
      skill_exams: skill_exams,
      skill_references: skill_references
    } do
      UpdateSkillPanels.call(@locked_date, true)

      # スキルユニットの公開データ生成がロールバックされることを確認
      published_skill_units = Repo.all(SkillUnit)
      assert length(published_skill_units) == length(skill_units)

      Enum.each(skill_units, fn skill_unit ->
        published_skill_unit =
          Enum.find(published_skill_units, fn %{trace_id: trace_id} ->
            trace_id == skill_unit.trace_id
          end)

        assert published_skill_unit.locked_date == @before_locked_date
        assert published_skill_unit.name == skill_unit.name

        # カテゴリの公開データ生成がロールバックされることを確認
        skill_categories = skill_unit.skill_categories

        published_skill_categories = Repo.all(Ecto.assoc(published_skill_unit, :skill_categories))

        assert length(published_skill_categories) == length(skill_categories)

        Enum.each(skill_categories, fn skill_category ->
          published_skill_category =
            Enum.find(published_skill_categories, fn %{trace_id: trace_id} ->
              trace_id == skill_category.trace_id
            end)

          assert published_skill_category.skill_unit_id == published_skill_unit.id
          assert published_skill_category.name == skill_category.name
          assert published_skill_category.position == skill_category.position

          # スキルの公開データ生成がロールバックされることを確認
          skills = skill_category.skills
          published_skills = Repo.all(Ecto.assoc(published_skill_category, :skills))
          assert length(published_skills) == length(skills)

          Enum.each(skills, fn skill ->
            published_skill =
              Enum.find(published_skills, fn %{trace_id: trace_id} ->
                trace_id == skill.trace_id
              end)

            assert published_skill.skill_category_id == published_skill_category.id
            assert published_skill.name == skill.name
            assert published_skill.position == skill.position
          end)
        end)
      end)

      # スキルクラスの公開データ生成がロールバックされることを確認
      published_skill_classes = Repo.all(SkillClass)
      assert length(published_skill_classes) == length(skill_classes)

      Enum.each(skill_classes, fn skill_class ->
        published_skill_class =
          Enum.find(published_skill_classes, fn %{trace_id: trace_id} ->
            trace_id == skill_class.trace_id
          end)

        assert published_skill_class.skill_panel_id == skill_class.skill_panel_id
        assert published_skill_class.locked_date == @before_locked_date
        assert published_skill_class.name == skill_class.name
        assert published_skill_class.class == skill_class.class
      end)

      # スキルユニットとスキルクラスの中間テーブルの公開データ生成がロールバックされることを確認
      published_skill_class_units = Repo.all(SkillClassUnit)
      assert length(published_skill_class_units) == length(skill_class_units)

      Enum.each(skill_class_units, fn skill_class_unit ->
        published_skill_class_unit =
          Enum.find(published_skill_class_units, fn %{trace_id: trace_id} ->
            trace_id == skill_class_unit.trace_id
          end)

        published_skill_unit =
          Enum.find(published_skill_units, fn %{trace_id: trace_id} ->
            trace_id == skill_class_unit.skill_unit.trace_id
          end)

        published_skill_class =
          Enum.find(published_skill_classes, fn %{trace_id: trace_id} ->
            trace_id == skill_class_unit.skill_class.trace_id
          end)

        assert published_skill_class_unit.skill_unit_id == published_skill_unit.id
        assert published_skill_class_unit.skill_class_id == published_skill_class.id
        assert published_skill_class_unit.position == skill_class_unit.position
      end)

      # スキルユニット単位の集計の公開データ生成がロールバックされることを確認
      published_skill_unit_scores = Repo.all(SkillUnitScore) |> Repo.preload(:skill_unit)
      assert length(published_skill_unit_scores) == length(skill_unit_scores)

      Enum.each(skill_unit_scores, fn skill_unit_score ->
        published_skill_unit_score =
          Enum.find(published_skill_unit_scores, fn %{
                                                      user_id: user_id,
                                                      skill_unit: %{trace_id: trace_id}
                                                    } ->
            user_id == skill_unit_score.user_id &&
              trace_id == skill_unit_score.skill_unit.trace_id
          end)

        assert published_skill_unit_score.percentage == skill_unit_score.percentage
      end)

      # スキル単位のスコアの公開データ生成がロールバックされることを確認
      published_skill_scores = Repo.all(SkillScore) |> Repo.preload(:skill)
      assert length(published_skill_scores) == length(skill_scores)

      Enum.each(skill_scores, fn skill_score ->
        published_skill_score =
          Enum.find(published_skill_scores, fn %{user_id: user_id, skill: %{trace_id: trace_id}} ->
            user_id == skill_score.user_id && trace_id == skill_score.skill.trace_id
          end)

        assert published_skill_score.score == skill_score.score
        assert published_skill_score.exam_progress == skill_score.exam_progress
        assert published_skill_score.reference_read == skill_score.reference_read
        assert published_skill_score.evidence_filled == skill_score.evidence_filled
      end)

      # スキルクラス単位の集計の公開データ生成がロールバックされることを確認
      published_skill_class_scores = Repo.all(SkillClassScore) |> Repo.preload(:skill_class)
      assert length(published_skill_class_scores) == length(skill_class_scores)

      Enum.each(skill_class_scores, fn skill_class_score ->
        published_skill_class_score =
          Enum.find(published_skill_class_scores, fn %{
                                                       user_id: user_id,
                                                       skill_class: %{trace_id: trace_id}
                                                     } ->
            user_id == skill_class_score.user_id &&
              trace_id == skill_class_score.skill_class.trace_id
          end)

        assert published_skill_class_score.level == skill_class_score.level
        assert published_skill_class_score.percentage == skill_class_score.percentage
      end)

      # キャリアフィールド単位の集計の公開データ生成がロールバックされることを確認
      published_career_field_scores = Repo.all(CareerFieldScore)
      assert length(published_career_field_scores) == length(career_field_scores)

      Enum.each(career_field_scores, fn career_field_score ->
        published_career_field_score =
          Enum.find(published_career_field_scores, fn %{
                                                        user_id: user_id,
                                                        career_field_id: career_field_id
                                                      } ->
            user_id == career_field_score.user_id &&
              career_field_id == career_field_score.career_field_id
          end)

        assert published_career_field_score.percentage == career_field_score.percentage

        assert published_career_field_score.high_skills_count ==
                 career_field_score.high_skills_count
      end)

      # エビデンスのデータ更新がロールバックされることを確認
      updated_skill_evidences = Repo.all(SkillEvidence) |> Repo.preload(:skill)
      assert length(updated_skill_evidences) == length(skill_evidences)

      Enum.each(skill_evidences, fn skill_evidence ->
        updated_skill_evidence =
          Enum.find(updated_skill_evidences, fn %{id: id} ->
            id == skill_evidence.id
          end)

        assert updated_skill_evidence.skill.trace_id == skill_evidence.skill.trace_id
      end)

      # 試験のデータ更新がロールバックされることを確認
      updated_skill_exams = Repo.all(SkillExam) |> Repo.preload(:skill)
      assert length(updated_skill_exams) == length(skill_exams)

      Enum.each(skill_exams, fn skill_exam ->
        updated_skill_exam =
          Enum.find(updated_skill_exams, fn %{id: id} ->
            id == skill_exam.id
          end)

        assert updated_skill_exam.skill.trace_id == skill_exam.skill.trace_id
      end)

      # 教材のデータ更新がロールバックされることを確認
      updated_skill_references = Repo.all(SkillReference) |> Repo.preload(:skill)
      assert length(updated_skill_references) == length(skill_references)

      Enum.each(skill_references, fn skill_reference ->
        updated_skill_reference =
          Enum.find(updated_skill_references, fn %{id: id} ->
            id == skill_reference.id
          end)

        assert updated_skill_reference.skill.trace_id == skill_reference.skill.trace_id
      end)

      # スキルユニットの履歴データ生成がロールバックされることを確認
      historical_skill_units = Repo.all(HistoricalSkillUnit)
      assert Enum.empty?(historical_skill_units)

      # スキルクラスの履歴データ生成がロールバックされることを確認
      historical_skill_classes = Repo.all(HistoricalSkillClass)
      assert Enum.empty?(historical_skill_classes)

      # スキルユニットとスキルクラスの中間テーブルの履歴データ生成がロールバックされることを確認
      historical_skill_class_units = Repo.all(HistoricalSkillClassUnit)
      assert Enum.empty?(historical_skill_class_units)

      # スキルユニット単位の集計の履歴データ生成がロールバックされることを確認
      historical_skill_unit_scores = Repo.all(HistoricalSkillUnitScore)
      assert Enum.empty?(historical_skill_unit_scores)

      # スキル単位のスコアの履歴データ生成がロールバックされることを確認
      historical_skill_scores = Repo.all(HistoricalSkillScore)
      assert Enum.empty?(historical_skill_scores)

      # スキルクラス単位の集計の履歴データ生成がロールバックされることを確認
      historical_skill_class_scores = Repo.all(HistoricalSkillClassScore)
      assert Enum.empty?(historical_skill_class_scores)

      # キャリアフィールド単位の集計の履歴データ生成がロールバックされることを確認
      historical_career_field_scores = Repo.all(HistoricalCareerFieldScore)
      assert Enum.empty?(historical_career_field_scores)
    end
  end
end
