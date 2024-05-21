defmodule BrightWeb.Admin.InterviewLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  @create_attrs %{
    skill_params: "some skill_params",
    status: :waiting_decision,
    comment: "some comment"
  }
  @update_attrs %{
    skill_params: "some updated skill_params",
    status: :consume_interview,
    comment: "some updated comment"
  }
  @invalid_attrs %{
    skill_params: nil,
    comment: nil,
    recruiter_user_id: nil,
    candidates_user_id: nil
  }

  defp create_interview(_) do
    interview =
      insert(:interview,
        recruiter_user_id: insert(:user).id,
        candidates_user_id: insert(:user).id
      )

    %{interview: interview}
  end

  describe "Index" do
    setup [:create_interview]

    test "lists all recruit_interview", %{conn: conn, interview: interview} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/recruits/interviews")

      assert html =~ "Listing Recruit inteview"
      assert html =~ interview.comment
    end

    test "saves new interview", %{conn: conn} do
      create_attrs =
        Map.merge(@create_attrs, %{
          recruiter_user_id: insert(:user).id,
          candidates_user_id: insert(:user).id
        })

      {:ok, index_live, _html} = live(conn, ~p"/admin/recruits/interviews")

      assert index_live |> element("a", "New Interview") |> render_click() =~
               "New Interview"

      assert_patch(index_live, ~p"/admin/recruits/interviews/new")

      assert index_live
             |> form("#interview-form", interview: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#interview-form", interview: create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/recruits/interviews")

      html = render(index_live)
      assert html =~ "Interview created successfully"
      assert html =~ "some comment"
    end

    test "updates interview in listing", %{conn: conn, interview: interview} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/recruits/interviews")

      assert index_live
             |> element("#interviews-#{interview.id} a", "Edit")
             |> render_click() =~
               "Edit Interview"

      assert_patch(index_live, ~p"/admin/recruits/interviews/#{interview}/edit")

      assert index_live
             |> form("#interview-form", interview: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/recruits/interviews")

      html = render(index_live)
      assert html =~ "Interview updated successfully"
      assert html =~ "some updated comment"
    end

    test "deletes interview in listing", %{conn: conn, interview: interview} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/recruits/interviews")

      assert index_live
             |> element("#interviews-#{interview.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#interview-#{interview.id}")
    end
  end

  describe "Show" do
    setup [:create_interview]

    test "displays interview", %{conn: conn, interview: interview} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/recruits/interviews/#{interview}")

      assert html =~ "Show Interview"
      assert html =~ interview.comment
    end

    test "updates interview within modal", %{conn: conn, interview: interview} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/recruits/interviews/#{interview}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Interview"

      assert_patch(show_live, ~p"/admin/recruits/interviews/#{interview}/show/edit")

      assert show_live
             |> form("#interview-form", interview: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/recruits/interviews/#{interview}")

      html = render(show_live)
      assert html =~ "Interview updated successfully"
      assert html =~ "some updated comment"
    end
  end
end
