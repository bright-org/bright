defmodule BrightWeb.UserForgotPasswordLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  import Swoosh.TestAssertions

  alias Bright.Accounts
  alias Bright.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/users/reset_password")

      assert html =~ "パスワードを忘れた方へ"
      assert has_element?(lv, ~s|a[href="/users/log_in"]|, "戻る")
    end

    test "redirects log_in page when click 戻る button", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password")

      lv
      |> element("a", "戻る")
      |> render_click()
      |> follow_redirect(conn, ~p"/users/log_in")
    end

    test "redirects onboardings if already logged in and does not finish onboarding", %{
      conn: conn
    } do
      result =
        conn
        |> log_in_user(insert(:user))
        |> live(~p"/users/reset_password")
        |> follow_redirect(conn, ~p"/onboardings/welcome")

      assert {:ok, _conn} = result
    end

    test "redirects if already logged in and finished onboarding", %{conn: conn} do
      user = insert(:user)
      insert(:user_onboarding, user: user)

      result =
        conn
        |> log_in_user(user)
        |> live(~p"/users/reset_password")
        |> follow_redirect(conn, ~p"/graphs")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{user: insert(:user)}
    end

    test "sends a new reset password token", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password")

      {:ok, _conn} =
        lv
        |> form("#reset_password_form", user: %{"email" => user.email})
        |> render_submit()
        |> follow_redirect(conn, "/users/send_reset_password_url")

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context ==
               "reset_password"

      assert_reset_password_mail_sent(user)
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password")

      {:ok, _conn} =
        lv
        |> form("#reset_password_form", user: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/users/send_reset_password_url")

      assert Repo.all(Accounts.UserToken) == []
      assert_no_email_sent()
    end

    test "does not send reset password token if user.password_registered is false", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password")

      user = insert(:user, password_registered: false)

      {:ok, _conn} =
        lv
        |> form("#reset_password_form", user: %{"email" => user.email})
        |> render_submit()
        |> follow_redirect(conn, "/users/send_reset_password_url")

      assert Repo.all(Accounts.UserToken) == []
      assert_no_email_sent()
    end

    test "does not send reset password token if user is not confirmed", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password")

      user = insert(:user_not_confirmed)

      {:ok, _conn} =
        lv
        |> form("#reset_password_form", user: %{"email" => user.email})
        |> render_submit()
        |> follow_redirect(conn, "/users/send_reset_password_url")

      assert Repo.all(Accounts.UserToken) == []
      assert_no_email_sent()
    end
  end
end
