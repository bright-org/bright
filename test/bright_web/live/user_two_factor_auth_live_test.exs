defmodule BrightWeb.UserTwoFactorAuthLiveTest do
  use BrightWeb.ConnCase

  alias Bright.Accounts.User2faCodes
  alias Bright.Accounts
  alias Bright.Repo
  import Phoenix.LiveViewTest
  import Bright.Factory

  setup %{conn: conn} do
    user = insert(:user)
    session_token = Accounts.setup_user_2fa_auth(user)
    user_2fa_code = Repo.get_by!(User2faCodes, user_id: user.id)

    %{
      conn: conn,
      user: user,
      session_token: session_token,
      user_2fa_code: user_2fa_code
    }
  end

  describe "GET /users/two_factor_auth/:token" do
    test "invalid token", %{conn: conn} do
      {:error, {:redirect, to}} = conn |> live(~p"/users/two_factor_auth/aaaaa")

      assert to == %{
               flash: %{"error" => "セッションの期限が切れました。再度ログインしてください。"},
               to: ~p"/users/log_in"
             }
    end

    test "renders page", %{conn: conn, session_token: session_token} do
      {:ok, _lv, html} = conn |> live(~p"/users/two_factor_auth/#{session_token}")

      assert html =~ "2段階認証"
      assert html =~ "メールに届いた認証コードを入力し「次へ進む」を押してください。"
    end

    test "redirects log in page when clicks 戻る button", %{
      conn: conn,
      session_token: session_token
    } do
      {:ok, lv, _html} = conn |> live(~p"/users/two_factor_auth/#{session_token}")

      lv
      |> element("a", "戻る")
      |> render_click()
      |> follow_redirect(conn, ~p"/users/log_in")
    end

    test "redirects using new token and setup two factor auth again when clicks 再送信する button", %{
      conn: conn,
      user: user,
      session_token: session_token,
      user_2fa_code: user_2fa_code
    } do
      {:ok, lv, _html} = conn |> live(~p"/users/two_factor_auth/#{session_token}")

      lv
      |> element("a", "再送信する")
      |> render_click()

      {path, flash} = assert_redirect(lv)

      assert path =~ "/users/two_factor_auth/"

      assert flash == %{
               "info" => "確認メールを再送しました。"
             }

      assert user_2fa_code != Repo.get_by!(User2faCodes, user_id: user.id)
      refute Accounts.get_user_by_2fa_auth_session_token(session_token)
    end

    test "redirects onboarding page and does user log_in when submits valid code", %{
      conn: conn,
      session_token: session_token,
      user_2fa_code: user_2fa_code
    } do
      {:ok, lv, _html} = conn |> live(~p"/users/two_factor_auth/#{session_token}")

      conn =
        lv
        |> form("#two_factor_auth_code", %{
          "user_2fa_code" => %{
            code: user_2fa_code.code,
            token: session_token
          }
        })
        |> submit_form(conn)

      assert get_session(conn, :user_token)
      assert conn.resp_cookies["_bright_web_user"]
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "ログインしました"
      assert redirected_to(conn) == ~p"/onboardings"
    end

    test "redirects mypage and does user log_in when submits valid code and onboarding was finished",
         %{
           conn: conn,
           user: user,
           session_token: session_token,
           user_2fa_code: user_2fa_code
         } do
      insert(:user_onboarding, user: user)
      {:ok, lv, _html} = conn |> live(~p"/users/two_factor_auth/#{session_token}")

      conn =
        lv
        |> form("#two_factor_auth_code", %{
          "user_2fa_code" => %{
            code: user_2fa_code.code,
            token: session_token
          }
        })
        |> submit_form(conn)

      assert get_session(conn, :user_token)
      assert conn.resp_cookies["_bright_web_user"]
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "ログインしました"
      assert redirected_to(conn) == ~p"/mypage"
    end

    test "redirects back with flash submits invalid code", %{
      conn: conn,
      session_token: session_token
    } do
      {:ok, lv, _html} = conn |> live(~p"/users/two_factor_auth/#{session_token}")

      conn =
        lv
        |> form("#two_factor_auth_code", %{
          "user_2fa_code" => %{
            code: "123456789",
            token: session_token
          }
        })
        |> submit_form(conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "2段階認証コードが正しくないか期限切れです"
      assert redirected_to(conn) == ~p"/users/two_factor_auth/#{session_token}"
    end

    test "redirects log in page with flash submits invalid token", %{
      conn: conn,
      session_token: session_token,
      user_2fa_code: user_2fa_code
    } do
      {:ok, lv, _html} = conn |> live(~p"/users/two_factor_auth/#{session_token}")

      conn =
        lv
        |> form("#two_factor_auth_code", %{
          "user_2fa_code" => %{
            code: user_2fa_code.code,
            token: "invalid_token"
          }
        })
        |> submit_form(conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "セッションの期限が切れました。再度ログインしてください。"
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end
end
