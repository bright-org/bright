defmodule Bright.Batches.UpdateSkillPanelsTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.Batches.UpdateSkillPanels

  describe "call/1" do
    alias Bright.Repo

    alias Bright.HistoricalSkillUnits.{HistoricalSkillUnit, HistoricalSkillClassUnit}
    alias Bright.HistoricalSkillPanels.HistoricalSkillClass

    @locked_date Date.utc_today()
    @before_locked_date Date.add(@locked_date, -30)

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

    test "create historical skill panels", %{
      skill_units: skill_units,
      skill_classes: skill_classes,
      skill_class_units: skill_class_units
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
    end
  end
end
