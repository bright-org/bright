defmodule BrightWeb.OAuthControllerTest do
  use BrightWeb.ConnCase, async: false

  import Bright.Factory
  alias Bright.Repo
  alias Bright.Accounts.SocialIdentifierToken
  alias Bright.Accounts.UserSocialAuth
  import ExUnit.CaptureLog

  @name "koyo"
  @email "dummy@example.com"
  @github_nickname "koyo-miyamura"

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

    test "redirects when provider is github", %{conn: conn} do
      conn = get(conn, ~p"/auth/github")

      assert %URI{
               path: "/login/oauth/authorize",
               query: query
             } = redirected_to(conn) |> URI.parse()

      assert %{
               "client_id" => "dummy_client_id",
               "redirect_uri" => "http://www.example.com/auth/github/callback",
               "response_type" => "code",
               "scope" => "",
               "state" => state
             } = URI.decode_query(query)

      assert is_binary(state)
    end
  end

  defp setup_for_google_auth(%{conn: conn}) do
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

  defp setup_for_github_auth(%{conn: conn}) do
    # NOTE: state パラメータ付きでリクエストしないと CSRF エラーになるので事前に生成しておく
    conn =
      conn
      |> get(~p"/auth/github")

    state =
      redirected_to(conn)
      |> URI.parse()
      |> Map.get(:query)
      |> URI.decode_query()
      |> Map.get("state")

    %{conn: conn |> recycle(), state: state, provider: :github}
  end

  # NOTE: Bright.Ueberauth.Strategy.Test を前提としたテスト
  describe "GET /auth/:provider/callback when provider is google" do
    setup [:setup_for_google_auth]

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

      assert %SocialIdentifierToken{name: @name, email: @email, display_name: @email} =
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
      assert redirected_to(conn) == ~p"/onboardings/welcome"
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
      assert redirected_to(conn) == ~p"/mypage"
    end
  end

  describe "GET /auth/:provider/callback when provider is github" do
    setup [:setup_for_github_auth]

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
        strategy: Ueberauth.Strategy.Github
      }

      log =
        capture_log([level: :warn], fn ->
          conn =
            conn
            |> assign(:ueberauth_failure, ueberauth_failure)
            |> get(~p"/auth/github/callback", %{"state" => state})

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
      identifier = 1

      ueberauth_auth = %Ueberauth.Auth{
        info: %Ueberauth.Auth.Info{name: @name, email: @email, nickname: @github_nickname},
        provider: provider,
        uid: identifier
      }

      conn =
        conn
        |> assign(:ueberauth_auth, ueberauth_auth)
        |> get(~p"/auth/github/callback", %{"state" => state})

      # 具体的なリダイレクト先はハッシュ化された token によって決まるので部分一致で判定する
      assert redirected_to(conn) =~ "/users/register_social_account/"

      assert %SocialIdentifierToken{name: @name, email: @email, display_name: @github_nickname} =
               Repo.get_by(SocialIdentifierToken,
                 provider: provider,
                 identifier: to_string(identifier)
               )
    end

    test "redirects log in page in when OAuth is success and user by provider and identifier is already registered and but not confirmed",
         %{
           conn: conn,
           state: state,
           provider: provider
         } do
      identifier = 1
      user = insert(:user_not_confirmed)
      insert(:user_social_auth_for_github, user: user, identifier: to_string(identifier))

      ueberauth_auth = %Ueberauth.Auth{
        info: %Ueberauth.Auth.Info{name: @name, nickname: @github_nickname},
        provider: provider,
        uid: identifier
      }

      conn =
        conn
        |> assign(:ueberauth_auth, ueberauth_auth)
        |> get(~p"/auth/github/callback", %{"state" => state})

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
      identifier = 1
      insert(:user_social_auth_for_github, identifier: to_string(identifier))

      ueberauth_auth = %Ueberauth.Auth{
        info: %Ueberauth.Auth.Info{name: @name, nickname: @github_nickname},
        provider: provider,
        uid: identifier
      }

      conn =
        conn
        |> assign(:ueberauth_auth, ueberauth_auth)
        |> get(~p"/auth/github/callback", %{"state" => state})

      assert get_session(conn, :user_token)
      assert conn.resp_cookies["_bright_web_user"]
      assert redirected_to(conn) == ~p"/onboardings/welcome"
    end
  end

  describe "GET /auth/:provider/callback when provider is google and user logs in" do
    setup [:setup_for_google_auth, :register_and_log_in_user]

    test "links social accounts", %{conn: conn, user: user, state: state, provider: provider} do
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

      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "連携しました"
      assert redirected_to(conn) == ~p"/mypage"

      assert %{display_name: @email, identifier: ^identifier} =
               Repo.get_by(UserSocialAuth, user_id: user.id, provider: provider)
    end

    test "cannot link social accounts when other user already links", %{
      conn: conn,
      user: user,
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

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "すでに他のユーザーと連携済みです"
      assert redirected_to(conn) == ~p"/mypage"
      refute Repo.get_by(UserSocialAuth, user_id: user.id, provider: provider)
    end

    test "cannot link social accounts when user already links with the provider", %{
      conn: conn,
      user: user,
      state: state,
      provider: provider
    } do
      insert(:user_social_auth_for_google, user: user, identifier: "10")

      ueberauth_auth = %Ueberauth.Auth{
        info: %Ueberauth.Auth.Info{name: @name, email: @email},
        provider: provider,
        uid: "1"
      }

      conn =
        conn
        |> assign(:ueberauth_auth, ueberauth_auth)
        |> get(~p"/auth/google/callback", %{"state" => state})

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "連携に失敗しました"
      assert redirected_to(conn) == ~p"/mypage"
      assert Repo.aggregate(UserSocialAuth, :count) == 1
    end
  end

  describe "GET /auth/:provider/callback when provider is github and user logs in" do
    setup [:setup_for_github_auth, :register_and_log_in_user]

    test "links social accounts", %{
      conn: conn,
      user: %{id: user_id},
      state: state,
      provider: provider
    } do
      identifier = 1

      ueberauth_auth = %Ueberauth.Auth{
        info: %Ueberauth.Auth.Info{name: @name, email: @email, nickname: @github_nickname},
        provider: provider,
        uid: identifier
      }

      conn =
        conn
        |> assign(:ueberauth_auth, ueberauth_auth)
        |> get(~p"/auth/github/callback", %{"state" => state})

      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "連携しました"
      assert redirected_to(conn) == ~p"/mypage"

      identifier = to_string(identifier)

      assert %UserSocialAuth{
               display_name: @github_nickname,
               identifier: ^identifier
             } = Repo.get_by(UserSocialAuth, user_id: user_id, provider: provider)
    end
  end

  describe "DELETE /auth/:provider" do
    setup [:register_and_log_in_user]

    test "deletes user_social_auth", %{conn: conn, user: user} do
      insert(:user_social_auth_for_google, user: user, identifier: "1")

      conn = conn |> delete(~p"/auth/google")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "連携解除しました"
      assert redirected_to(conn) == ~p"/mypage"
      refute Repo.exists?(UserSocialAuth)
    end

    test "does not raise error when already deleted", %{conn: conn} do
      conn = conn |> delete(~p"/auth/google")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "連携解除しました"
      assert redirected_to(conn) == ~p"/mypage"
    end
  end

  describe "DELETE /auth/:provider when social login user" do
    setup [:register_and_log_in_social_account_user]

    test "does not delete when deletes last social account", %{conn: conn} do
      conn = conn |> delete(~p"/auth/google")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "SNS連携は少なくとも一つ必要なため連携解除できません"
      assert redirected_to(conn) == ~p"/mypage"
    end
  end
end
