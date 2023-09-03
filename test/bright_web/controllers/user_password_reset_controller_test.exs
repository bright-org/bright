defmodule BrightWeb.UserPasswordResetControllerTest do
  use BrightWeb.ConnCase, async: true

  import Bright.Factory
  alias Bright.Repo
  alias Bright.Accounts.UserToken
  alias Bright.Accounts

  setup %{conn: conn} do
    current_password = "password1"
    user = create_user_with_password(current_password)
    insert(:user_onboarding, user: user)
    %{conn: log_in_user(conn, user), user: user, current_password: current_password}
  end

  describe "POST /users/password_reset" do
    test "updates user password and deletes token and log in", %{
      conn: conn,
      user: user,
      current_password: current_password
    } do
      new_password = "password2"

      before_user_token = Repo.get_by(UserToken, user_id: user.id, context: "session")

      conn =
        post(conn, ~p"/users/password_reset", %{
          "current_password" => current_password,
          "user" => %{"password" => new_password, "password_confirmation" => new_password}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "パスワードを更新しました"
      assert redirected_to(conn) == ~p"/mypage"
      assert Accounts.get_user_by_email_and_password(user.email, new_password)
      assert get_session(conn, :user_token)
      assert conn.resp_cookies["_bright_web_user"]
      assert conn.resp_cookies["_bright_web_user"].max_age == 60 * 60 * 24 * 60
      refute Repo.get(UserToken, before_user_token.id)
    end

    test "fails to update user password when current password is invalid", %{
      conn: conn,
      user: user
    } do
      new_password = "password2"
      before_user_token = Repo.get_by(UserToken, user_id: user.id, context: "session")

      conn =
        post(conn, ~p"/users/password_reset", %{
          "current_password" => "not_currrent_password",
          "user" => %{"password" => new_password, "password_confirmation" => new_password}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "パスワードの更新に失敗しました"
      assert redirected_to(conn) == ~p"/mypage"
      refute Accounts.get_user_by_email_and_password(user.email, new_password)
      assert Repo.get(UserToken, before_user_token.id)
    end

    test "fails to update user password when password confirmation is invalid", %{
      conn: conn,
      user: user,
      current_password: current_password
    } do
      new_password = "password2"
      before_user_token = Repo.get_by(UserToken, user_id: user.id, context: "session")

      conn =
        post(conn, ~p"/users/password_reset", %{
          "current_password" => current_password,
          "user" => %{"password" => new_password, "password_confirmation" => "not_match"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "パスワードの更新に失敗しました"
      assert redirected_to(conn) == ~p"/mypage"
      refute Accounts.get_user_by_email_and_password(user.email, new_password)
      assert Repo.get(UserToken, before_user_token.id)
    end
  end
end
