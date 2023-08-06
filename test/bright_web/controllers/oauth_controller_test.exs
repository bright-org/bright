defmodule BrightWeb.OAuthControllerTest do
  use BrightWeb.ConnCase, async: false

  import Bright.Factory
  alias Bright.Repo
  alias Bright.Accounts.SocialIdentifierToken
  import ExUnit.CaptureLog

  @name "koyo"
  @email "dummy@example.com"

  describe "GET /auth/:provider" do
    test "redirects when provider is google", %{conn: conn} do
      conn = get(conn, ~p"/auth/google")

      assert %URI{
               path: "/o/oauth2/v2/auth",
               query: query
             } = redirected_to(conn) |> URI.parse()

      assert %{
               "client_id" => "dummy_client_id",
               "redirect_uri" => "http://www.example.com/auth/google/callback",
               "response_type" => "code",
               "scope" => "email profile",
               "state" => state
             } = URI.decode_query(query)

      assert is_binary(state)
    end
  end

  # NOTE: Bright.Ueberauth.Strategy.Test を前提としたテスト
  describe "GET /auth/:provider/callback when provider is google" do
    setup %{conn: conn} do
      # NOTE: state パラメータ付きでリクエストしないと CSRF エラーになるので事前に生成しておく
      conn =
        conn
        |> get(~p"/auth/google")

      state =
        redirected_to(conn)
        |> URI.parse()
        |> Map.get(:query)
        |> URI.decode_query()
        |> Map.get("state")

      %{conn: conn |> recycle(), state: state, provider: :google}
    end

    test "redirects and logs when OAuth is failure", %{
      conn: conn,
      state: state,
      provider: provider
    } do
      ueberauth_failure = %Ueberauth.Failure{
        errors: %Ueberauth.Failure.Error{
          message: "error message",
          message_key: "error message_key"
        },
        provider: provider,
        strategy: Ueberauth.Strategy.Google
      }

      log =
        capture_log([level: :warn], fn ->
          conn =
            conn
            |> assign(:ueberauth_failure, ueberauth_failure)
            |> get(~p"/auth/google/callback", %{"state" => state})

          assert redirected_to(conn) == ~p"/users/register"
          assert Phoenix.Flash.get(conn.assigns.flash, :error) == "認証に失敗しました"
        end)

      assert log =~ inspect(ueberauth_failure)
    end

    test "generates social identifier token and redirects when OAuth is success and no user by provider and identifier exists",
         %{
           conn: conn,
           state: state,
           provider: provider
         } do
      identifier = "1"

      ueberauth_auth = %Ueberauth.Auth{
        info: %Ueberauth.Auth.Info{name: @name, email: @email},
        provider: provider,
        uid: identifier
      }

      conn =
        conn
        |> assign(:ueberauth_auth, ueberauth_auth)
        |> get(~p"/auth/google/callback", %{"state" => state})

      # 具体的なリダイレクト先はハッシュ化された token によって決まるので部分一致で判定する
      assert redirected_to(conn) =~ "/users/register_social_account/"

      assert %{name: @name, email: @email} =
               Repo.get_by(SocialIdentifierToken, provider: provider, identifier: identifier)
    end

    test "redirects log in page in when OAuth is success and user by provider and identifier is already registered and but not confirmed",
         %{
           conn: conn,
           state: state,
           provider: provider
         } do
      identifier = "1"
      user = insert(:user_not_confirmed)
      insert(:user_social_auth_for_google, user: user, identifier: identifier)

      ueberauth_auth = %Ueberauth.Auth{
        info: %Ueberauth.Auth.Info{name: @name, email: @email},
        provider: provider,
        uid: identifier
      }

      conn =
        conn
        |> assign(:ueberauth_auth, ueberauth_auth)
        |> get(~p"/auth/google/callback", %{"state" => state})

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "メールアドレス未確認ユーザーです。メールを確認して確認済みにしてください。"

      assert redirected_to(conn) == ~p"/users/log_in"
    end

    test "logs in when OAuth is success and user by provider and identifier is already registered and confirmed",
         %{
           conn: conn,
           state: state,
           provider: provider
         } do
      identifier = "1"
      insert(:user_social_auth_for_google, identifier: identifier)

      ueberauth_auth = %Ueberauth.Auth{
        info: %Ueberauth.Auth.Info{name: @name, email: @email},
        provider: provider,
        uid: identifier
      }

      conn =
        conn
        |> assign(:ueberauth_auth, ueberauth_auth)
        |> get(~p"/auth/google/callback", %{"state" => state})

      assert get_session(conn, :user_token)
      assert conn.resp_cookies["_bright_web_user"]
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "ログインしました"
      assert redirected_to(conn) == ~p"/onboardings"
    end

    test "logs in and redirects mypage when OAuth is success and user by provider and identifier is already registered and confirmed and finished onboarding",
         %{
           conn: conn,
           state: state,
           provider: provider
         } do
      identifier = "1"
      user = insert(:user)
      insert(:user_social_auth_for_google, user: user, identifier: identifier)
      insert(:user_onboarding, user: user)

      ueberauth_auth = %Ueberauth.Auth{
        info: %Ueberauth.Auth.Info{name: @name, email: @email},
        provider: provider,
        uid: identifier
      }

      conn =
        conn
        |> assign(:ueberauth_auth, ueberauth_auth)
        |> get(~p"/auth/google/callback", %{"state" => state})

      assert get_session(conn, :user_token)
      assert conn.resp_cookies["_bright_web_user"]
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "ログインしました"
      assert redirected_to(conn) == ~p"/mypage"
    end
  end
end
