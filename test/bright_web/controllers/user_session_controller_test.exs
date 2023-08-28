defmodule BrightWeb.UserSessionControllerTest do
  use BrightWeb.ConnCase, async: true

  import Bright.Factory
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

      assert_two_factor_auth_mail_sent(user)
    end

    test "redirects two_factor_auth page when two factor auth done cookie exists but was expired",
         %{
           conn: conn,
           user: user
         } do
      conn =
        set_two_factor_auth_done(conn, user)
        |> tap(fn _conn ->
          UserToken.user_and_contexts_query(user, ["two_factor_auth_done"])
          |> Repo.update_all(
            set: [
              inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.add(-1 * 60 * 60 * 24 * 60)
            ]
          )
        end)
        |> post(~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      # 具体的なリダイレクト先はハッシュ化された token によって決まるので部分一致で判定する
      assert redirected_to(conn) =~ "/users/two_factor_auth/"

      assert Repo.get_by(UserToken, user_id: user.id, context: "two_factor_auth_session")
      assert Repo.get_by(User2faCodes, user_id: user.id)

      assert_two_factor_auth_mail_sent(user)
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
      assert redirected_to(conn) == ~p"/onboardings/welcome"
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

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "メールアドレスまたはパスワードが不正です"
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/users/log_out")
      assert redirected_to(conn) == ~p"/users/log_in"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "ログアウトしました"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/users/log_out")
      assert redirected_to(conn) == ~p"/users/log_in"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "ログアウトしました"
    end
  end
end
