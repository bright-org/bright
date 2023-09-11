defmodule BrightWeb.GraphLive.GraphsTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  describe "Show" do
    setup [:register_and_log_in_user]

    setup %{user: user} do
      skill_panel = insert(:skill_panel)
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    test "shows content", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      {:ok, show_live, html} = live(conn, ~p"/graphs/#{skill_panel}")

      assert html =~ skill_panel.name

      assert show_live
             |> has_element?("#class_tab_1", skill_class.name)
    end

    test "shows content without parameters", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      {:ok, show_live, html} = live(conn, ~p"/graphs")

      assert html =~ skill_panel.name

      assert show_live
             |> has_element?("#class_tab_1", skill_class.name)
    end
  end

  describe "Show no skill panel" do
    setup [:register_and_log_in_user]

    test "show content with no skill panel message", %{conn: conn} do
      {:ok, show_live, html} = live(conn, ~p"/graphs")

      assert html =~ "スキルパネルがありません"

      show_live
      |> element("a", "スキルを選ぶ")
      |> render_click()

      {path, _} = assert_redirect(show_live)
      assert path == "/onboardings"
    end
  end
end