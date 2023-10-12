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

  describe "historical_skill_class" do
    test "get_historical_skill_class_on_date returns a historical_skill_class on locked_date" do
      skill_panel = insert(:historical_skill_panel)

      historical_skill_class_month_7 =
        insert(:historical_skill_class,
          skill_panel: skill_panel,
          class: 1,
          locked_date: ~D[2023-07-01]
        )

      historical_skill_class_month_4 =
        insert(:historical_skill_class,
          skill_panel: skill_panel,
          class: 1,
          locked_date: ~D[2023-04-01]
        )

      historical_skill_class =
        HistoricalSkillPanels.get_historical_skill_class_on_date(
          skill_panel_id: skill_panel.id,
          class: 1,
          date: ~D[2023-10-01]
        )

      assert historical_skill_class.id == historical_skill_class_month_7.id

      ret =
        HistoricalSkillPanels.get_historical_skill_class_on_date(
          skill_panel_id: skill_panel.id,
          class: 1,
          date: ~D[2023-07-01]
        )

      assert ret.id == historical_skill_class_month_4.id
    end

    test "get_historical_skill_class_on_date returns a historical_skill_class on skill_panel_id" do
      skill_panel_1 = insert(:historical_skill_panel)
      skill_panel_2 = insert(:historical_skill_panel)

      _historical_skill_class_1 =
        insert(:historical_skill_class,
          skill_panel: skill_panel_1,
          class: 1,
          locked_date: ~D[2023-07-01]
        )

      historical_skill_class_2 =
        insert(:historical_skill_class,
          skill_panel: skill_panel_2,
          class: 1,
          locked_date: ~D[2023-07-01]
        )

      ret =
        HistoricalSkillPanels.get_historical_skill_class_on_date(
          skill_panel_id: skill_panel_2.id,
          class: 1,
          date: ~D[2023-10-01]
        )

      assert ret.id == historical_skill_class_2.id
    end

    test "get_historical_skill_class_on_date returns a historical_skill_class on class" do
      skill_panel = insert(:historical_skill_panel)

      _historical_skill_class_1 =
        insert(:historical_skill_class,
          skill_panel: skill_panel,
          class: 1,
          locked_date: ~D[2023-07-01]
        )

      historical_skill_class_2 =
        insert(:historical_skill_class,
          skill_panel: skill_panel,
          class: 2,
          locked_date: ~D[2023-07-01]
        )

      ret =
        HistoricalSkillPanels.get_historical_skill_class_on_date(
          skill_panel_id: skill_panel.id,
          class: 2,
          date: ~D[2023-10-01]
        )

      assert ret.id == historical_skill_class_2.id
    end
  end
end
