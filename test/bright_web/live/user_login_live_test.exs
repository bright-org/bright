defmodule BrightWeb.UserLoginLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Log in page" do
    test "renders log in page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/log_in")

      assert html =~ "ログイン"
      assert html =~ "ユーザー新規作成はこちら"
      assert html =~ "パスワードを忘れた方はこちら"
      assert html =~ "確認メールの再送はこちら"
    end

    test "redirects onboardings if already logged in and does not finish onboarding", %{
      conn: conn
    } do
      result =
        conn
        |> log_in_user(insert(:user))
        |> live(~p"/users/log_in")
        |> follow_redirect(conn, ~p"/onboardings/welcome")

      assert {:ok, _conn} = result
    end

    test "redirects if already logged in and finished onboarding", %{conn: conn} do
      user = insert(:user)
      insert(:user_onboarding, user: user)

      result =
        conn
        |> log_in_user(user)
        |> live(~p"/users/log_in")
        |> follow_redirect(conn, ~p"/graphs")

      assert {:ok, _conn} = result
    end
  end

  describe "user login" do
    test "redirects if user login with valid credentials", %{conn: conn} do
      password = "123456789abcd"

      user = create_user_with_password(password)

      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      form = form(lv, "#login_form", user: %{email: user.email, password: password})

      conn = submit_form(form, conn)

      assert redirected_to(conn) =~ ~p"/users/two_factor_auth/"
    end

    test "redirects if user already done two factor auth in operating browser",
         %{conn: conn} do
      password = "123456789abcd"

      user = create_user_with_password(password)
      insert(:user_onboarding, user: user)

      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      form = form(lv, "#login_form", user: %{email: user.email, password: password})

      conn = conn |> set_two_factor_auth_done(user) |> then(&submit_form(form, &1))

      assert redirected_to(conn) == ~p"/graphs"
    end

    test "redirects if user already finished onboardings and already done two factor auth in operating browser",
         %{conn: conn} do
      password = "123456789abcd"

      user = create_user_with_password(password)
      insert(:user_onboarding, user: user)

      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      form = form(lv, "#login_form", user: %{email: user.email, password: password})

      conn = conn |> set_two_factor_auth_done(user) |> then(&submit_form(form, &1))

      assert redirected_to(conn) == ~p"/graphs"
    end

    test "redirects to login page with a flash error if there are no valid credentials", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      form = form(lv, "#login_form", user: %{email: "test@email.com", password: "123456"})

      conn = submit_form(form, conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "メールアドレスまたはパスワードが不正です"

      assert redirected_to(conn) == "/users/log_in"
    end
  end

  describe "login navigation" do
    test "redirects to registration page when the Register button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      {:ok, _login_live, login_html} =
        lv
        |> element("a", "ユーザー新規作成はこちら")
        |> render_click()
        |> follow_redirect(conn, ~p"/users/register")

      assert login_html =~ "ユーザー新規作成"
    end

    test "redirects to forgot password page when the Forgot Password link is clicked", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      {:ok, conn} =
        lv
        |> element("a", "パスワードを忘れた方はこちら")
        |> render_click()
        |> follow_redirect(conn, ~p"/users/reset_password")

      assert conn.resp_body =~ "パスワードを忘れた方へ"
    end

    test "redirects to confirm instructions page when the confirm instructions link is clicked",
         %{
           conn: conn
         } do
      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      {:ok, conn} =
        lv
        |> element("a", "確認メールの再送はこちら")
        |> render_click()
        |> follow_redirect(conn, ~p"/users/confirm")

      assert conn.resp_body =~ "確認メールが届かなかった方へ"
    end
  end

  describe "SNS link button" do
    test "shows sns link buttons", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      assert lv
             |> has_element?(
               ~s{a[href="/auth/google"]},
               "Google"
             )

      assert lv
             |> has_element?(
               ~s{a[href="/auth/github"]},
               "GitHub"
             )

      assert lv
             |> has_element?(
               ~s{a[href="#"]},
               "Facebook"
             )

      assert lv
             |> has_element?(
               ~s{a[href="#"]},
               "X"
             )
    end

    test "clicks 「Google」 button", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      lv
      |> element(
        "a",
        "Google"
      )
      |> render_click()
      |> follow_redirect(conn, ~p"/auth/google")
    end

    test "clicks 「GitHub」 button", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      lv
      |> element(
        "a",
        "GitHub"
      )
      |> render_click()
      |> follow_redirect(conn, ~p"/auth/github")
    end
  end
end
