defmodule BrightWeb.Admin.JobSkillPanelLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.JobsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_job_skill_panel(_) do
    job_skill_panel = job_skill_panel_fixture()
    %{job_skill_panel: job_skill_panel}
  end

  describe "Index" do
    setup [:create_job_skill_panel]

    test "lists all job_skill_panels", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/job_skill_panels")

      assert html =~ "Listing Job skill panels"
    end

    test "saves new job_skill_panel", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/job_skill_panels")

      assert index_live |> element("a", "New Job skill panel") |> render_click() =~
               "New Job skill panel"

      assert_patch(index_live, ~p"/admin/job_skill_panels/new")

      assert index_live
             |> form("#job_skill_panel-form", job_skill_panel: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#job_skill_panel-form", job_skill_panel: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/job_skill_panels")

      html = render(index_live)
      assert html =~ "Job skill panel created successfully"
    end

    test "updates job_skill_panel in listing", %{conn: conn, job_skill_panel: job_skill_panel} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/job_skill_panels")

      assert index_live |> element("#job_skill_panels-#{job_skill_panel.id} a", "Edit") |> render_click() =~
               "Edit Job skill panel"

      assert_patch(index_live, ~p"/admin/job_skill_panels/#{job_skill_panel}/edit")

      assert index_live
             |> form("#job_skill_panel-form", job_skill_panel: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#job_skill_panel-form", job_skill_panel: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/job_skill_panels")

      html = render(index_live)
      assert html =~ "Job skill panel updated successfully"
    end

    test "deletes job_skill_panel in listing", %{conn: conn, job_skill_panel: job_skill_panel} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/job_skill_panels")

      assert index_live |> element("#job_skill_panels-#{job_skill_panel.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#job_skill_panels-#{job_skill_panel.id}")
    end
  end

  describe "Show" do
    setup [:create_job_skill_panel]

    test "displays job_skill_panel", %{conn: conn, job_skill_panel: job_skill_panel} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/job_skill_panels/#{job_skill_panel}")

      assert html =~ "Show Job skill panel"
    end

    test "updates job_skill_panel within modal", %{conn: conn, job_skill_panel: job_skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/job_skill_panels/#{job_skill_panel}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Job skill panel"

      assert_patch(show_live, ~p"/admin/job_skill_panels/#{job_skill_panel}/show/edit")

      assert show_live
             |> form("#job_skill_panel-form", job_skill_panel: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#job_skill_panel-form", job_skill_panel: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/job_skill_panels/#{job_skill_panel}")

      html = render(show_live)
      assert html =~ "Job skill panel updated successfully"
    end
  end
end
