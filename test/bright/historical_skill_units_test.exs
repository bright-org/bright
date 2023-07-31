defmodule Bright.HistoricalSkillUnitsTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.HistoricalSkillUnits

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
end
