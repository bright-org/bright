defmodule BrightWeb.SkillPanelLive.SkillsTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Show" do
    setup [:register_and_log_in_user]

    test "shows content", %{conn: conn} do
      {:ok, _show_live, html} = live(conn, ~p"/panels/hoge/skills")

      assert html =~ "スキル一覧"
    end
  end
end
