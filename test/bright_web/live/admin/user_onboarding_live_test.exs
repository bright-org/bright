defmodule BrightWeb.Admin.UserOnboardingLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  @create_attrs %{completed_at: "2023-07-08T11:20:00"}
  @update_attrs %{completed_at: "2023-07-09T11:20:00"}
  @invalid_attrs %{completed_at: nil}

  defp create_user_onboarding(_) do
    user_onboarding = insert(:user_onboarding)
    %{user_onboarding: user_onboarding}
  end

  describe "Index" do
    setup [:create_user_onboarding]

    test "lists all user_onboardings", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/user_onboardings")

      assert html =~ "Listing User onboardings"
    end

    test "saves new user_onboarding", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/user_onboardings")

      assert index_live |> element("a", "New User onboarding") |> render_click() =~
               "New User onboarding"

      assert_patch(index_live, ~p"/admin/user_onboardings/new")

      assert index_live
             |> form("#user_onboarding-form", user_onboarding: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#user_onboarding-form", user_onboarding: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/user_onboardings")

      html = render(index_live)
      assert html =~ "User onboarding created successfully"
    end

    test "updates user_onboarding in listing", %{conn: conn, user_onboarding: user_onboarding} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/user_onboardings")

      assert index_live
             |> element("#user_onboardings-#{user_onboarding.id} a", "Edit")
             |> render_click() =~
               "Edit User onboarding"

      assert_patch(index_live, ~p"/admin/user_onboardings/#{user_onboarding}/edit")

      assert index_live
             |> form("#user_onboarding-form", user_onboarding: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#user_onboarding-form", user_onboarding: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/user_onboardings")

      html = render(index_live)
      assert html =~ "User onboarding updated successfully"
    end

    test "deletes user_onboarding in listing", %{conn: conn, user_onboarding: user_onboarding} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/user_onboardings")

      assert index_live
             |> element("#user_onboardings-#{user_onboarding.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#user_onboardings-#{user_onboarding.id}")
    end
  end

  describe "Show" do
    setup [:create_user_onboarding]

    test "displays user_onboarding", %{conn: conn, user_onboarding: user_onboarding} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/user_onboardings/#{user_onboarding}")

      assert html =~ "Show User onboarding"
    end

    test "updates user_onboarding within modal", %{conn: conn, user_onboarding: user_onboarding} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/user_onboardings/#{user_onboarding}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit User onboarding"

      assert_patch(show_live, ~p"/admin/user_onboardings/#{user_onboarding}/show/edit")

      assert show_live
             |> form("#user_onboarding-form", user_onboarding: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert show_live
             |> form("#user_onboarding-form", user_onboarding: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/user_onboardings/#{user_onboarding}")

      html = render(show_live)
      assert html =~ "User onboarding updated successfully"
    end
  end
end
