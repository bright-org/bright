defmodule BrightWeb.UserRegistrationLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

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
        |> follow_redirect(conn, ~p"/onboardings")

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
            "name" => String.duplicate("a", 101),
            "email" => "with spaces",
            "password" => "short"
          }
        )

      assert result =~ "ユーザー新規作成"
      assert result =~ "100文字以内で入力してください"
      assert result =~ "無効なフォーマットです"
      assert result =~ "8文字以上で入力してください"
    end
  end

  describe "register user" do
    test "creates account and redirect finish registartion page", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      name = unique_user_name()
      email = unique_user_email()

      form(lv, "#registration_form",
        user:
          params_for(:user_before_registration, name: name, email: email)
          |> Map.take([:name, :email, :password])
      )
      |> render_submit()
      |> follow_redirect(conn, ~p"/users/finish_registration")
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = insert(:user, email: "test@email.com")

      result =
        lv
        |> form("#registration_form",
          user: %{"email" => user.email, "password" => "valid_password"}
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
end
