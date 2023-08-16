defmodule BrightWeb.UserTwoFactorAuthControllerTest do
  use BrightWeb.ConnCase, async: true

  import Bright.Factory
  alias Bright.Accounts
  alias Bright.Accounts.UserToken

  describe "POST /users/two_factor_auth" do
    test "validates code with token", %{conn: conn} do
      user = insert(:user)
      user_2fa_code = insert(:user_2fa_code, user: user)
      {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_session")
      insert(:user_token, user_token |> Map.from_struct())

      conn =
        post(conn, ~p"/users/two_factor_auth", %{
          "user_2fa_code" => %{"code" => user_2fa_code.code, "token" => token}
        })

      # Assert user two factor auth done cookie and token
      assert %{value: _value, same_site: "Lax", max_age: max_age} =
               conn.resp_cookies["_bright_web_user_2fa_done"]

      user_2fa_done_token =
        fetch_cookies(conn, signed: ["_bright_web_user_2fa_done"])
        |> Map.fetch!(:cookies)
        |> Map.fetch!("_bright_web_user_2fa_done")

      assert max_age == 60 * 60 * 24 * 60
      assert user == Accounts.get_user_by_2fa_done_token(user_2fa_done_token)

      # Assert user session cookie
      assert get_session(conn, :user_token)
      assert conn.resp_cookies["_bright_web_user"]
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "ログインしました"
      assert redirected_to(conn) == ~p"/onboardings"
    end

    test "varidates code and redirects mypage if onboarding was finished", %{conn: conn} do
      user = insert(:user)
      insert(:user_onboarding, user: user)
      user_2fa_code = insert(:user_2fa_code, user: user)
      {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_session")
      insert(:user_token, user_token |> Map.from_struct())

      conn =
        post(conn, ~p"/users/two_factor_auth", %{
          "user_2fa_code" => %{"code" => user_2fa_code.code, "token" => token}
        })

      assert redirected_to(conn) == ~p"/mypage"
    end

    test "redirects back if code is invalid", %{conn: conn} do
      user = insert(:user)
      {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_session")
      insert(:user_token, user_token |> Map.from_struct())

      conn =
        post(conn, ~p"/users/two_factor_auth", %{
          "user_2fa_code" => %{"code" => "aaaaaa", "token" => token}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "2段階認証コードが正しくないか期限切れです"
      assert redirected_to(conn) == ~p"/users/two_factor_auth/#{token}"
    end

    test "redirects back if code was expired after 10 minutes", %{conn: conn} do
      user = insert(:user)
      {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_session")

      user_2fa_code =
        insert(:user_2fa_code,
          user: user,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.add(-10 * 60)
        )

      insert(:user_token, user_token |> Map.from_struct())

      conn =
        post(conn, ~p"/users/two_factor_auth", %{
          "user_2fa_code" => %{"code" => user_2fa_code.code, "token" => token}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "2段階認証コードが正しくないか期限切れです"
      assert redirected_to(conn) == ~p"/users/two_factor_auth/#{token}"
    end

    test "redirects log in page if token is invalid", %{conn: conn} do
      user = insert(:user)
      user_2fa_code = insert(:user_2fa_code, user: user)

      conn =
        post(conn, ~p"/users/two_factor_auth", %{
          "user_2fa_code" => %{"code" => user_2fa_code.code, "token" => "aaaaaa"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "セッションの期限が切れました。再度ログインしてください。"
      assert redirected_to(conn) =~ ~p"/users/log_in"
    end

    test "redirects log in page if token was expired after 1 hours", %{conn: conn} do
      user = insert(:user)
      user_2fa_code = insert(:user_2fa_code, user: user)
      {token, user_token} = UserToken.build_user_token(user, "two_factor_auth_session")

      insert(
        :user_token,
        user_token
        |> Map.from_struct()
        |> Map.put(
          :inserted_at,
          NaiveDateTime.utc_now() |> NaiveDateTime.add(-1 * 60 * 60)
        )
      )

      conn =
        post(conn, ~p"/users/two_factor_auth", %{
          "user_2fa_code" => %{"code" => user_2fa_code.code, "token" => token}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "セッションの期限が切れました。再度ログインしてください。"
      assert redirected_to(conn) =~ ~p"/users/log_in"
    end
  end
end
