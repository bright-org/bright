defmodule BrightWeb.UserSessionControllerTest do
  use BrightWeb.ConnCase, async: true

  import Bright.Factory
  import Swoosh.TestAssertions
  alias Bright.Accounts.UserToken
  alias Bright.Accounts.User2faCodes
  alias Bright.Repo

  import Ecto.Query, warn: false

  setup %{conn: conn} do
    %{user: insert(:user), conn: conn}
  end

  describe "POST /users/log_in" do
    test "redirects two_factor_auth page when two factor auth done cookie does not exist", %{
      conn: conn,
      user: user
    } do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      # 具体的なリダイレクト先はハッシュ化された token によって決まるので部分一致で判定する
      assert redirected_to(conn) =~ "/users/two_factor_auth/"

      assert Repo.get_by(UserToken, user_id: user.id, context: "two_factor_auth_session")
      assert Repo.get_by(User2faCodes, user_id: user.id)

      assert_email_sent(fn email ->
        assert email.subject == "【Bright】二段階認証コード"
        assert email.to == [{"", user.email}]
      end)
    end

    test "logs the user in when two factor auth done cookie exists", %{conn: conn, user: user} do
      conn =
        set_two_factor_auth_done(conn, user)
        |> post(~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert get_session(conn, :user_token)
      assert conn.resp_cookies["_bright_web_user"]
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "ログインしました"
      assert redirected_to(conn) == ~p"/onboardings"
    end

    test "redirects mypage if user already finished onboardings", %{conn: conn, user: user} do
      insert(:user_onboarding, user: user)

      conn =
        set_two_factor_auth_done(conn, user)
        |> post(~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "ログインしました"
      assert redirected_to(conn) == ~p"/mypage"
    end

    test "login following password update", %{conn: conn, user: user} do
      conn =
        conn
        |> post(~p"/users/log_in", %{
          "_action" => "password_updated",
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      assert redirected_to(conn) == ~p"/users/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/users/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/users/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
