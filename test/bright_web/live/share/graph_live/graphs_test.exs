defmodule BrightWeb.Share.GraphLive.GraphsTest do
  alias BrightWeb.Share.Token
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Show" do
    setup do
      create_user_with_skill()
    end

    setup %{user: user, skill_class_1: skill_class_1} do
      %{share_graph_token: Token.encode_share_graph_token(user.id, skill_class_1.id)}
    end

    test "shows header", %{conn: conn, share_graph_token: share_graph_token} do
      {:ok, live, _html} = live(conn, "/share/#{share_graph_token}/graphs")

      assert live |> has_element?(~s{a[href="/users/register"]}, "Brightを体験してみる")
    end

    test "shows skill profile", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill_class_1: skill_class_1,
      skill_class_2: skill_class_2,
      skill_class_3: skill_class_3,
      share_graph_token: share_graph_token
    } do
      {:ok, live, _html} = live(conn, "/share/#{share_graph_token}/graphs")

      assert live |> has_element?("#profile-skill-panel-name", skill_panel.name)
      assert live |> has_element?("span", to_string(skill_class_1.class))
      assert live |> has_element?("span", skill_class_1.name)
      refute live |> has_element?("body", to_string(skill_class_2.class))
      refute live |> has_element?("body", skill_class_2.name)
      refute live |> has_element?("body", to_string(skill_class_3.class))
      refute live |> has_element?("body", skill_class_3.name)

      refute live |> has_element?("body", user.name)

      assert live |> has_element?("#doughnut-graph-single")
    end

    test "shows skill gem", %{conn: conn, share_graph_token: share_graph_token} do
      {:ok, _live, html} = live(conn, "/share/#{share_graph_token}/graphs")

      assert html =~ "該当時期には未だスキルパネルがアンロックされていません"
    end

    test "shows graph", %{conn: conn, share_graph_token: share_graph_token} do
      {:ok, live, _html} = live(conn, "/share/#{share_graph_token}/graphs")

      assert live |> has_element?("#growth-graph")
      assert live |> has_element?("#growth-graph-sp")
    end
  end
end
