defmodule BrightWeb.SkillPanelLive.GraphTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  describe "Show" do
    setup [:register_and_log_in_user]

    setup do
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    test "shows content", %{conn: conn, skill_panel: skill_panel} do
      {:ok, _show_live, html} = live(conn, ~p"/panels/dummy_id/graph")

      assert html =~ skill_panel.name
    end
  end
end
