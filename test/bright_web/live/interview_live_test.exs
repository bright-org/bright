defmodule BrightWeb.InterviewLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.RecruitsFixtures

  @create_attrs %{
    skill_params: "some skill_params",
    status: "some status",
    comment: "some comment"
  }
  @update_attrs %{
    skill_params: "some updated skill_params",
    status: "some updated status",
    comment: "some updated comment"
  }
  @invalid_attrs %{skill_params: nil, status: nil}

  defp create_interview(_) do
    interview = interview_fixture()
    %{interview: interview}
  end

  describe "Index" do
    setup [:create_interview]

    test "lists all recruit_interview", %{conn: conn, interview: interview} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/recruit_interviews")

      assert html =~ "Listing Recruit inteview"
      assert html =~ interview.skill_params
    end

    test "saves new interview", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/recruit_interviews")

      assert index_live |> element("a", "New Interview") |> render_click() =~
               "New Interview"

      assert_patch(index_live, ~p"/admin/recruit_interviews/new")

      assert index_live
             |> form("#interview-form", interview: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#interview-form", interview: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/recruit_interviews")

      html = render(index_live)
      assert html =~ "Interview created successfully"
      assert html =~ "some skill_params"
    end

    test "updates interview in listing", %{conn: conn, interview: interview} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/recruit_interviews")

      assert index_live
             |> element("#recruit_interview-#{interview.id} a", "Edit")
             |> render_click() =~
               "Edit Interview"

      assert_patch(index_live, ~p"/admin/recruit_interviews/#{interview}/edit")

      assert index_live
             |> form("#interview-form", interview: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#interview-form", interview: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/recruit_interviews")

      html = render(index_live)
      assert html =~ "Interview updated successfully"
      assert html =~ "some updated skill_params"
    end

    test "deletes interview in listing", %{conn: conn, interview: interview} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/recruit_interviews")

      assert index_live
             |> element("#recruit_interview-#{interview.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#recruit_interview-#{interview.id}")
    end
  end

  describe "Show" do
    setup [:create_interview]

    test "displays interview", %{conn: conn, interview: interview} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/recruit_interviews/#{interview}")

      assert html =~ "Show Interview"
      assert html =~ interview.skill_params
    end

    test "updates interview within modal", %{conn: conn, interview: interview} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/recruit_interviews/#{interview}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Interview"

      assert_patch(show_live, ~p"/admin/recruit_interviews/#{interview}/show/edit")

      assert show_live
             |> form("#interview-form", interview: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#interview-form", interview: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/recruit_interviews/#{interview}")

      html = render(show_live)
      assert html =~ "Interview updated successfully"
      assert html =~ "some updated skill_params"
    end
  end
end
