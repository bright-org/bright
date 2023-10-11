defmodule BrightWeb.UserRegistrationLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory
  alias Bright.Repo
  alias Bright.Accounts.User
  alias Bright.Accounts.UserToken

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "ユーザー新規作成"
    end

    test "redirects onboardings if already logged in and does not finish onboarding", %{
      conn: conn
    } do
      result =
        conn
        |> log_in_user(insert(:user))
        |> live(~p"/users/register")
        |> follow_redirect(conn, ~p"/onboardings/welcome")

      assert {:ok, _conn} = result
    end

    test "redirects mypage if already logged in and finished onboarding", %{conn: conn} do
      user = insert(:user)
      insert(:user_onboarding, user: user)

      result =
        conn
        |> log_in_user(user)
        |> live(~p"/users/register")
        |> follow_redirect(conn, ~p"/mypage")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(
          user: %{
            "name" => String.duplicate("a", 31),
            "email" => "with spaces",
            "password" => "short"
          }
        )

      assert result =~ "ユーザー新規作成"
      assert result =~ "30文字以内で入力してください"
      assert result =~ "無効なフォーマットです"
      assert result =~ "8文字以上で入力してください"
    end
  end

  describe "register user" do
    test "creates account and redirect finish registartion page", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      name = unique_user_name()
      email_address = unique_user_email()

      form(lv, "#registration_form",
        user:
          params_for(:user_before_registration, name: name, email: email_address)
          |> Map.take([:name, :email, :password])
      )
      |> render_submit()
      |> follow_redirect(conn, ~p"/users/finish_registration")

      assert_confirmation_mail_sent(email_address)

      user = Repo.get_by(User, name: name)

      assert user
      refute user.confirmed_at
      assert user.password_registered
      assert Repo.get_by(UserToken, user_id: user.id, context: "confirm")
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = insert(:user, email: "test@email.com")

      result =
        lv
        |> form("#registration_form",
          user: %{"email" => user.email, "password" => "valid_password1"}
        )
        |> render_submit()

      assert result =~ "すでに使用されています"
    end

    test "renders errors for duplicated email in sub email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user_sub_email = insert(:user_sub_email, email: "test@email.com")

      result =
        lv
        |> form("#registration_form",
          user: %{"email" => user_sub_email.email, "password" => "valid_password1"}
        )
        |> render_submit()

      assert result =~ "すでに使用されています"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element("a", "ログインはこちら")
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert login_html =~ "ログイン"
    end
  end

  describe "SNS link button" do
    test "shows sns link buttons", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

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
               "Twitter"
             )
    end

    test "clicks 「Google」 button", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      lv
      |> element(
        "a",
        "Google"
      )
      |> render_click()
      |> follow_redirect(conn, ~p"/auth/google")
    end

    test "clicks 「Github」 button", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

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
