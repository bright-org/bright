defmodule Bright.HistoricalSkillUnitsTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.HistoricalSkillUnits

  # @current_tl ~D[2023-10-01]
  @back_tl_1 ~D[2023-07-01]

  describe "historical_skill_units" do
    test "list_historical_skill_units/0 returns all historical_skill_units" do
      historical_skill_unit = insert(:historical_skill_unit)
      assert HistoricalSkillUnits.list_historical_skill_units() == [historical_skill_unit]
    end

    test "get_historical_skill_unit!/1 returns the historical_skill_unit with given id" do
      historical_skill_unit = insert(:historical_skill_unit)

      assert HistoricalSkillUnits.get_historical_skill_unit!(historical_skill_unit.id) ==
               historical_skill_unit
    end
  end

  describe "historical_skills" do
    test "list_historical_skills_on_historical_skill_class" do
      # ダミーと合わせて２つのスキルクラスとスキルを用意
      [{historical_skill_class, historical_skill}, _] =
        insert_pair(:historical_skill_class,
          skill_panel: build(:historical_skill_panel),
          class: 1,
          locked_date: @back_tl_1
        )
        |> Enum.map(fn historical_skill_class ->
          historical_skill_unit = insert(:historical_skill_unit)

          insert(:historical_skill_class_unit,
            historical_skill_class_id: historical_skill_class.id,
            historical_skill_unit_id: historical_skill_unit.id
          )

          historical_skill_category =
            insert(:historical_skill_category,
              historical_skill_unit: historical_skill_unit,
              position: 1
            )

          historical_skill =
            insert(:historical_skill,
              historical_skill_category: historical_skill_category,
              position: 1
            )

          {historical_skill_class, historical_skill}
        end)

      ret =
        HistoricalSkillUnits.list_historical_skills_on_historical_skill_class(
          historical_skill_class
        )

      assert ret |> Enum.map(& &1.id) == [historical_skill.id]
    end
  end
end
