defmodule BrightWeb.UserRegistrationLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "ユーザー新規作成"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(insert(:user))
        |> live(~p"/users/register")
        |> follow_redirect(conn, "/mypage")

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
            "password" => "too short"
          }
        )

      assert result =~ "ユーザー新規作成"
      assert result =~ "should be at most 100 character(s)"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "should be at least 12 character"
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

      assert result =~ "has already been taken"
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
