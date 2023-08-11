defmodule BrightWeb.UserResetPasswordLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  alias Bright.Accounts

  setup do
    user = insert(:user)

    token =
      extract_user_token(fn url ->
        Accounts.deliver_user_reset_password_instructions(user, url)
      end)

    %{token: token, user: user}
  end

  describe "Reset password page" do
    test "renders reset password with valid token", %{conn: conn, token: token} do
      {:ok, _lv, html} = live(conn, ~p"/users/reset_password/#{token}")

      assert html =~ "パスワードをリセットする"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      {:error, {:redirect, to}} = live(conn, ~p"/users/reset_password/invalid")

      assert to == %{
               flash: %{"error" => "リンクが無効であるか期限が切れています"},
               to: ~p"/users/log_in"
             }
    end

    test "renders errors for invalid data", %{conn: conn, token: token} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password/#{token}")

      result =
        lv
        |> element("#reset_password_form")
        |> render_change(
          user: %{"password" => "short", "confirmation_password" => "secret123456"}
        )

      assert result =~ "8文字以上で入力してください"
      assert result =~ "パスワードが一致しません"
    end
  end

  describe "Reset Password" do
    test "resets password once", %{conn: conn, token: token, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password/#{token}")

      {:ok, conn} =
        lv
        |> form("#reset_password_form",
          user: %{
            "password" => "new valid password2",
            "password_confirmation" => "new valid password2"
          }
        )
        |> render_submit()
        |> follow_redirect(conn, ~p"/users/log_in")

      refute get_session(conn, :user_token)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password2")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password/#{token}")

      result =
        lv
        |> form("#reset_password_form",
          user: %{
            "password" => "short",
            "password_confirmation" => "does not match"
          }
        )
        |> render_submit()

      assert result =~ "パスワードをリセットする"
      assert result =~ "8文字以上で入力してください"
      assert result =~ "パスワードが一致しません"
    end
  end
end
