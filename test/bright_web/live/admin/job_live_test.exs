defmodule BrightWeb.Admin.JobLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  @create_attrs %{name: "some name", position: 42, description: "some description", rank: :basic}
  @update_attrs %{
    name: "some updated name",
    position: 43,
    description: "some updated description",
    rank: :advanced
  }
  @invalid_attrs %{name: nil, position: nil, description: nil}

  defp create_job(_) do
    job = insert(:job)
    %{job: job}
  end

  describe "Index" do
    setup [:create_job]

    test "lists all jobs", %{conn: conn, job: job} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/jobs")

      assert html =~ "Listing Jobs"
      assert html =~ job.name
    end

    test "saves new job", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/jobs")

      assert index_live |> element("a", "New Job") |> render_click() =~
               "New Job"

      assert_patch(index_live, ~p"/admin/jobs/new")

      assert index_live
             |> form("#job-form", job: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#job-form", job: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/jobs")

      html = render(index_live)
      assert html =~ "Job created successfully"
      assert html =~ "some name"
    end

    test "updates job in listing", %{conn: conn, job: job} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/jobs")

      assert index_live |> element("#jobs-#{job.id} a", "Edit") |> render_click() =~
               "Edit Job"

      assert_patch(index_live, ~p"/admin/jobs/#{job}/edit")

      assert index_live
             |> form("#job-form", job: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#job-form", job: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/jobs")

      html = render(index_live)
      assert html =~ "Job updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes job in listing", %{conn: conn, job: job} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/jobs")

      assert index_live |> element("#jobs-#{job.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#jobs-#{job.id}")
    end
  end

  describe "Show" do
    setup [:create_job]

    test "displays job", %{conn: conn, job: job} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/jobs/#{job}")

      assert html =~ "Show Job"
      assert html =~ job.name
    end

    test "updates job within modal", %{conn: conn, job: job} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/jobs/#{job}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Job"

      assert_patch(show_live, ~p"/admin/jobs/#{job}/show/edit")

      assert show_live
             |> form("#job-form", job: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert show_live
             |> form("#job-form", job: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/jobs/#{job}")

      html = render(show_live)
      assert html =~ "Job updated successfully"
      assert html =~ "some updated name"
    end
  end
end
