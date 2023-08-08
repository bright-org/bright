defmodule BrightWeb.Admin.CareerWantJobLiveTest do
  use BrightWeb.ConnCase

  # TODO: Bright.Factoryで対応する
  # import Phoenix.LiveViewTest
  # import Bright.JobsFixtures

  # @create_attrs %{}
  # @update_attrs %{}
  # @invalid_attrs %{}

  # defp create_career_want_job(_) do
  #   career_want_job = career_want_job_fixture()
  #   %{career_want_job: career_want_job}
  # end

  # describe "Index" do
  #   setup [:create_career_want_job]

  #   test "lists all career_want_jobs", %{conn: conn} do
  #     {:ok, _index_live, html} = live(conn, ~p"/admin/career_want_jobs")

  #     assert html =~ "Listing Career want jobs"
  #   end

  #   test "saves new career_want_job", %{conn: conn} do
  #     {:ok, index_live, _html} = live(conn, ~p"/admin/career_want_jobs")

  #     assert index_live |> element("a", "New Career want job") |> render_click() =~
  #              "New Career want job"

  #     assert_patch(index_live, ~p"/admin/career_want_jobs/new")

  #     assert index_live
  #            |> form("#career_want_job-form", career_want_job: @invalid_attrs)
  #            |> render_change() =~ "入力してください"

  #     assert index_live
  #            |> form("#career_want_job-form", career_want_job: @create_attrs)
  #            |> render_submit()

  #     assert_patch(index_live, ~p"/admin/career_want_jobs")

  #     html = render(index_live)
  #     assert html =~ "Career want job created successfully"
  #   end

  #   TODO: テスト後日対応
  #   test "updates career_want_job in listing", %{conn: conn, career_want_job: career_want_job} do
  #     {:ok, index_live, _html} = live(conn, ~p"/admin/career_want_jobs")

  #     assert index_live
  #            |> element("#career_want_jobs-#{career_want_job.id} a", "Edit")
  #            |> render_click() =~
  #              "Edit Career want job"

  #     assert_patch(index_live, ~p"/admin/career_want_jobs/#{career_want_job}/edit")

  #     assert index_live
  #            |> form("#career_want_job-form", career_want_job: @invalid_attrs)
  #            |> render_change() =~ "入力してください"

  #     assert index_live
  #            |> form("#career_want_job-form", career_want_job: @update_attrs)
  #            |> render_submit()

  #     assert_patch(index_live, ~p"/admin/career_want_jobs")

  #     html = render(index_live)
  #     assert html =~ "Career want job updated successfully"
  #   end

  #   TODO: テスト後日対応
  #   test "deletes career_want_job in listing", %{conn: conn, career_want_job: career_want_job} do
  #     {:ok, index_live, _html} = live(conn, ~p"/admin/career_want_jobs")

  #     assert index_live
  #            |> element("#career_want_jobs-#{career_want_job.id} a", "Delete")
  #            |> render_click()

  #     refute has_element?(index_live, "#career_want_jobs-#{career_want_job.id}")
  #   end
  # end

  # describe "Show" do
  #   setup [:create_career_want_job]

  #   test "displays career_want_job", %{conn: conn, career_want_job: career_want_job} do
  #     {:ok, _show_live, html} = live(conn, ~p"/admin/career_want_jobs/#{career_want_job}")

  #     assert html =~ "Show Career want job"
  #   end

  #   test "updates career_want_job within modal", %{conn: conn, career_want_job: career_want_job} do
  #     {:ok, show_live, _html} = live(conn, ~p"/admin/career_want_jobs/#{career_want_job}")

  #     assert show_live |> element("a", "Edit") |> render_click() =~
  #              "Edit Career want job"

  #     assert_patch(show_live, ~p"/admin/career_want_jobs/#{career_want_job}/show/edit")

  #     assert show_live
  #            |> form("#career_want_job-form", career_want_job: @invalid_attrs)
  #            |> render_change() =~ "入力してください"

  #     assert show_live
  #            |> form("#career_want_job-form", career_want_job: @update_attrs)
  #            |> render_submit()

  #     assert_patch(show_live, ~p"/admin/career_want_jobs/#{career_want_job}")

  #     html = render(show_live)
  #     assert html =~ "Career want job updated successfully"
  #   end
  # end
end
