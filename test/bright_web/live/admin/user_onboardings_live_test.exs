defmodule BrightWeb.Admin.UserOnboardingsLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.OnboardingsFixtures

  @create_attrs %{completed_at: "2023-07-08T11:20:00"}
  @update_attrs %{completed_at: "2023-07-09T11:20:00"}
  @invalid_attrs %{completed_at: nil}

  defp create_user_onboardings(_) do
    user_onboardings = user_onboardings_fixture()
    %{user_onboardings: user_onboardings}
  end

  describe "Index" do
    setup [:create_user_onboardings]

    test "lists all user_onboardings", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/user_onboardings")

      assert html =~ "Listing User onboardings"
    end

    test "saves new user_onboardings", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/user_onboardings")

      assert index_live |> element("a", "New User onboardings") |> render_click() =~
               "New User onboardings"

      assert_patch(index_live, ~p"/admin/user_onboardings/new")

      assert index_live
             |> form("#user_onboardings-form", user_onboardings: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#user_onboardings-form", user_onboardings: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/user_onboardings")

      html = render(index_live)
      assert html =~ "User onboardings created successfully"
    end

    test "updates user_onboardings in listing", %{conn: conn, user_onboardings: user_onboardings} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/user_onboardings")

      assert index_live |> element("#user_onboardings-#{user_onboardings.id} a", "Edit") |> render_click() =~
               "Edit User onboardings"

      assert_patch(index_live, ~p"/admin/user_onboardings/#{user_onboardings}/edit")

      assert index_live
             |> form("#user_onboardings-form", user_onboardings: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#user_onboardings-form", user_onboardings: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/user_onboardings")

      html = render(index_live)
      assert html =~ "User onboardings updated successfully"
    end

    test "deletes user_onboardings in listing", %{conn: conn, user_onboardings: user_onboardings} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/user_onboardings")

      assert index_live |> element("#user_onboardings-#{user_onboardings.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user_onboardings-#{user_onboardings.id}")
    end
  end

  describe "Show" do
    setup [:create_user_onboardings]

    test "displays user_onboardings", %{conn: conn, user_onboardings: user_onboardings} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/user_onboardings/#{user_onboardings}")

      assert html =~ "Show User onboardings"
    end

    test "updates user_onboardings within modal", %{conn: conn, user_onboardings: user_onboardings} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/user_onboardings/#{user_onboardings}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit User onboardings"

      assert_patch(show_live, ~p"/admin/user_onboardings/#{user_onboardings}/show/edit")

      assert show_live
             |> form("#user_onboardings-form", user_onboardings: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#user_onboardings-form", user_onboardings: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/user_onboardings/#{user_onboardings}")

      html = render(show_live)
      assert html =~ "User onboardings updated successfully"
    end
  end
end
