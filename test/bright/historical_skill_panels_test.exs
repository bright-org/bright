defmodule Bright.HistoricalSkillPanelsTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.HistoricalSkillPanels

  describe "skill_panels" do
    test "list_skill_panels/0 returns all skill_panels" do
      skill_panel = insert(:historical_skill_panel)
      assert HistoricalSkillPanels.list_skill_panels() == [skill_panel]
    end

    test "get_skill_panel!/1 returns the skill_panel with given id" do
      skill_panel = insert(:historical_skill_panel)
      assert HistoricalSkillPanels.get_skill_panel!(skill_panel.id) == skill_panel
    end
  end
end
