defmodule BrightWeb.Admin.SkillPanelLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  @create_attrs params_for(:skill_panel)
  @update_attrs params_for(:skill_panel)
  @invalid_attrs %{name: nil}

  defp create_skill_panel(_) do
    skill_panel =
      insert(:skill_panel,
        skill_classes: build_pair(:skill_class),
        career_fields: build_pair(:career_field)
      )

    %{skill_panel: skill_panel}
  end

  describe "Index" do
    setup [:create_skill_panel]

    test "lists all skill_panels", %{conn: conn, skill_panel: skill_panel} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/skill_panels")

      assert html =~ "Listing Skill panels"
      assert html =~ skill_panel.name
    end

    test "saves new skill_panel", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/skill_panels")

      assert index_live |> element("a", "New Skill panel") |> render_click() =~
               "New Skill panel"

      assert_patch(index_live, ~p"/admin/skill_panels/new")

      assert index_live
             |> form("#skill_panel-form", skill_panel: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#skill_panel-form", skill_panel: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/skill_panels")

      html = render(index_live)
      assert html =~ "Skill panel created successfully"
      assert html =~ @create_attrs.name
    end

    test "updates skill_panel in listing", %{conn: conn, skill_panel: skill_panel} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/skill_panels")

      assert index_live |> element("#skill_panels-#{skill_panel.id} a", "Edit") |> render_click() =~
               "Edit Skill panel"

      assert_patch(index_live, ~p"/admin/skill_panels/#{skill_panel}/edit")

      assert index_live
             |> form("#skill_panel-form", skill_panel: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#skill_panel-form", skill_panel: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/skill_panels")

      html = render(index_live)
      assert html =~ "Skill panel updated successfully"
      assert html =~ @update_attrs.name
    end

    test "deletes skill_panel in listing", %{conn: conn, skill_panel: skill_panel} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/skill_panels")

      assert index_live
             |> element("#skill_panels-#{skill_panel.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#skill_panels-#{skill_panel.id}")
    end
  end

  describe "Show" do
    setup [:create_skill_panel]

    test "displays skill_panel", %{conn: conn, skill_panel: skill_panel} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/skill_panels/#{skill_panel}")

      assert html =~ "Show Skill panel"
      assert html =~ skill_panel.name
    end

    test "updates skill_panel within modal", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/skill_panels/#{skill_panel}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Skill panel"

      assert_patch(show_live, ~p"/admin/skill_panels/#{skill_panel}/show/edit")

      assert show_live
             |> form("#skill_panel-form", skill_panel: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert show_live
             |> form("#skill_panel-form", skill_panel: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/skill_panels/#{skill_panel}")

      html = render(show_live)
      assert html =~ "Skill panel updated successfully"
      assert html =~ @update_attrs.name
    end
  end
end
