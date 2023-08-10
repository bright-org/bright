defmodule Bright.Batches.UpdateSkillPanelsTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.Batches.UpdateSkillPanels

  describe "call/1" do
    alias Bright.Repo

    alias Bright.HistoricalSkillUnits.{
      HistoricalSkillUnit,
      HistoricalSkillClassUnit,
      HistoricalSkill
    }

    alias Bright.HistoricalSkillPanels.HistoricalSkillClass

    alias Bright.HistoricalSkillScores.{
      HistoricalSkillUnitScore,
      HistoricalSkillScore,
      HistoricalSkillClassScore,
      HistoricalCareerFieldScore
    }

    @locked_date Date.utc_today()
    @before_locked_date Date.add(@locked_date, -30)

    # 公開スキルユニットのデータを準備
    setup do
      skill_units =
        insert_pair(:skill_unit, locked_date: @before_locked_date)
        |> Enum.map(fn skill_unit ->
          insert_pair(:skill_category, skill_unit: skill_unit)
          |> Enum.map(fn skill_category ->
            insert_pair(:skill, skill_category: skill_category)
          end)

          skill_unit
        end)
        |> Repo.preload(skill_categories: :skills)

      %{skill_units: skill_units}
    end

    # 公開スキルクラスのデータを準備
    setup %{skill_units: skill_units} do
      skill_panel = insert(:skill_panel)

      skill_classes =
        insert_pair(:skill_class, skill_panel: skill_panel, locked_date: @before_locked_date)

      skill_class_units = [
        insert(:skill_class_unit,
          skill_class: Enum.at(skill_classes, 0),
          skill_unit: Enum.at(skill_units, 0)
        ),
        insert(:skill_class_unit,
          skill_class: Enum.at(skill_classes, 0),
          skill_unit: Enum.at(skill_units, 1)
        ),
        insert(:skill_class_unit,
          skill_class: Enum.at(skill_classes, 1),
          skill_unit: Enum.at(skill_units, 1)
        )
      ]

      %{skill_classes: skill_classes, skill_class_units: skill_class_units}
    end

    # 公開スキルスコアのデータを準備
    setup %{skill_units: skill_units, skill_classes: skill_classes} do
      skill_unit_scores =
        Enum.flat_map(skill_units, fn skill_unit ->
          insert_pair(:skill_unit_score, skill_unit: skill_unit)
        end)

      skill_scores =
        Enum.flat_map(skill_units, fn skill_unit ->
          Enum.flat_map(skill_unit.skill_categories, fn skill_category ->
            Enum.flat_map(skill_category.skills, fn skill ->
              insert_pair(:skill_score, skill: skill)
            end)
          end)
        end)

      skill_class_scores =
        Enum.flat_map(skill_classes, fn skill_class ->
          insert_pair(:skill_class_score, skill_class: skill_class)
        end)

      career_field_scores = insert_pair(:career_field_score)

      %{
        skill_unit_scores: skill_unit_scores,
        skill_scores: skill_scores,
        skill_class_scores: skill_class_scores,
        career_field_scores: career_field_scores
      }
    end

    test "update skill panels", %{
      skill_units: skill_units,
      skill_classes: skill_classes,
      skill_class_units: skill_class_units,
      skill_unit_scores: skill_unit_scores,
      skill_scores: skill_scores,
      skill_class_scores: skill_class_scores,
      career_field_scores: career_field_scores
    } do
      UpdateSkillPanels.call(@locked_date)

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
      historical_skill_unit_scores = Repo.all(HistoricalSkillUnitScore)
      assert length(historical_skill_unit_scores) == length(skill_unit_scores)

      Enum.each(skill_unit_scores, fn skill_unit_score ->
        historical_skill_unit_score =
          Enum.find(historical_skill_unit_scores, fn %{user_id: user_id} ->
            user_id == skill_unit_score.user_id
          end)

        historical_skill_unit =
          Enum.find(historical_skill_units, fn %{trace_id: trace_id} ->
            trace_id == skill_unit_score.skill_unit.trace_id
          end)

        assert historical_skill_unit_score.user_id == skill_unit_score.user_id
        assert historical_skill_unit_score.historical_skill_unit_id == historical_skill_unit.id
        assert historical_skill_unit_score.locked_date == @locked_date
        assert historical_skill_unit_score.percentage == skill_unit_score.percentage
      end)

      # スキル単位のスコアの履歴データ生成を確認
      historical_skills = Repo.all(HistoricalSkill)
      historical_skill_scores = Repo.all(HistoricalSkillScore)
      assert length(historical_skill_scores) == length(skill_scores)

      Enum.each(skill_scores, fn skill_score ->
        historical_skill_score =
          Enum.find(historical_skill_scores, fn %{user_id: user_id} ->
            user_id == skill_score.user_id
          end)

        historical_skill =
          Enum.find(historical_skills, fn %{trace_id: trace_id} ->
            trace_id == skill_score.skill.trace_id
          end)

        assert historical_skill_score.user_id == skill_score.user_id
        assert historical_skill_score.historical_skill_id == historical_skill.id
        assert historical_skill_score.score == skill_score.score
      end)

      # スキルクラス単位の集計の履歴データ生成を確認
      historical_skill_class_scores = Repo.all(HistoricalSkillClassScore)
      assert length(historical_skill_class_scores) == length(skill_class_scores)

      Enum.each(skill_class_scores, fn skill_class_score ->
        historical_skill_class_score =
          Enum.find(historical_skill_class_scores, fn %{user_id: user_id} ->
            user_id == skill_class_score.user_id
          end)

        historical_skill_class =
          Enum.find(historical_skill_classes, fn %{trace_id: trace_id} ->
            trace_id == skill_class_score.skill_class.trace_id
          end)

        assert historical_skill_class_score.user_id == skill_class_score.user_id
        assert historical_skill_class_score.historical_skill_class_id == historical_skill_class.id
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
  end
end
