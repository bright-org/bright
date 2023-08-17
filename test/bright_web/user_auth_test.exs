defmodule BrightWeb.UserAuthTest do
  use BrightWeb.ConnCase, async: true

  alias Phoenix.LiveView
  alias Bright.Accounts
  alias BrightWeb.UserAuth
  import Bright.Factory

  @cookie_key "_bright_web_user"
  @user_2fa_cookie_key "_bright_web_user_2fa_done"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, BrightWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{user: insert(:user), conn: conn}
  end

  describe "write_2fa_auth_done_cookie/1" do
    test "writes cookie", %{conn: conn} do
      conn = UserAuth.write_2fa_auth_done_cookie(conn, "token")

      assert %{value: _value, max_age: max_age, same_site: "Lax"} =
               conn.resp_cookies[@user_2fa_cookie_key]

      assert max_age == 60 * 60 * 24 * 60
    end
  end

  describe "valid_2fa_auth_done_cookie_exists?/2" do
    test "returns true when cookie exist", %{conn: conn, user: user} do
      assert set_two_factor_auth_done(conn, user)
             |> UserAuth.valid_2fa_auth_done_cookie_exists?(user)
    end

    test "returns false when cookie exist but not own user", %{conn: conn, user: user} do
      other_user = insert(:user)

      refute set_two_factor_auth_done(conn, other_user)
             |> UserAuth.valid_2fa_auth_done_cookie_exists?(user)
    end

    test "returns false when cookie does not exist", %{conn: conn, user: user} do
      refute UserAuth.valid_2fa_auth_done_cookie_exists?(conn, user)
    end
  end

  describe "log_in_user/2" do
    test "stores the user token in the session", %{conn: conn, user: user} do
      conn = UserAuth.log_in_user(conn, user)
      assert token = get_session(conn, :user_token)
      assert get_session(conn, :live_socket_id) == "users_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == ~p"/onboardings"
      assert Accounts.get_user_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, user: user} do
      conn = conn |> put_session(:to_be_removed, "value") |> UserAuth.log_in_user(user)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects mypage if user already finished onboardings", %{conn: conn, user: user} do
      insert(:user_onboarding, user: user)
      conn = conn |> UserAuth.log_in_user(user)
      assert redirected_to(conn) == ~p"/mypage"
    end

    test "redirects to the configured path", %{conn: conn, user: user} do
      conn = conn |> UserAuth.log_in_user(user, "/hello")
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie", %{conn: conn, user: user} do
      conn = conn |> fetch_cookies() |> UserAuth.log_in_user(user)
      assert get_session(conn, :user_token) == conn.cookies[@cookie_key]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@cookie_key]
      assert signed_token != get_session(conn, :user_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_user/1" do
    test "erases session and cookies", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)

      conn =
        conn
        |> put_session(:user_token, user_token)
        |> put_req_cookie(@cookie_key, user_token)
        |> fetch_cookies()
        |> UserAuth.log_out_user()

      refute get_session(conn, :user_token)
      refute conn.cookies[@cookie_key]
      assert %{max_age: 0} = conn.resp_cookies[@cookie_key]
      assert redirected_to(conn) == ~p"/users/log_in"
      refute Accounts.get_user_by_session_token(user_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "users_sessions:abcdef-token"
      BrightWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> UserAuth.log_out_user()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if user is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> UserAuth.log_out_user()
      refute get_session(conn, :user_token)
      assert %{max_age: 0} = conn.resp_cookies[@cookie_key]
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "fetch_current_user/2" do
    test "authenticates user from session", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)
      conn = conn |> put_session(:user_token, user_token) |> UserAuth.fetch_current_user([])
      assert conn.assigns.current_user.id == user.id
    end

    test "authenticates user from cookies", %{conn: conn, user: user} do
      logged_in_conn = conn |> fetch_cookies() |> UserAuth.log_in_user(user)

      user_token = logged_in_conn.cookies[@cookie_key]
      %{value: signed_token} = logged_in_conn.resp_cookies[@cookie_key]

      conn =
        conn
        |> put_req_cookie(@cookie_key, signed_token)
        |> UserAuth.fetch_current_user([])

      assert conn.assigns.current_user.id == user.id
      assert get_session(conn, :user_token) == user_token

      assert get_session(conn, :live_socket_id) ==
               "users_sessions:#{Base.url_encode64(user_token)}"
    end

    test "does not authenticate if data is missing", %{conn: conn, user: user} do
      _ = Accounts.generate_user_session_token(user)
      conn = UserAuth.fetch_current_user(conn, [])
      refute get_session(conn, :user_token)
      refute conn.assigns.current_user
    end
  end

  describe "on_mount: mount_current_user" do
    test "assigns current_user based on a valid user_token", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)
      session = conn |> put_session(:user_token, user_token) |> get_session()

      {:cont, updated_socket} =
        UserAuth.on_mount(:mount_current_user, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_user.id == user.id
    end

    test "assigns nil to current_user assign if there isn't a valid user_token", %{conn: conn} do
      user_token = "invalid_token"
      session = conn |> put_session(:user_token, user_token) |> get_session()

      {:cont, updated_socket} =
        UserAuth.on_mount(:mount_current_user, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_user == nil
    end

    test "assigns nil to current_user assign if there isn't a user_token", %{conn: conn} do
      session = conn |> get_session()

      {:cont, updated_socket} =
        UserAuth.on_mount(:mount_current_user, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_user == nil
    end
  end

  describe "on_mount: ensure_authenticated" do
    test "authenticates current_user based on a valid user_token", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)
      session = conn |> put_session(:user_token, user_token) |> get_session()

      {:cont, updated_socket} =
        UserAuth.on_mount(:ensure_authenticated, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_user.id == user.id
    end

    test "redirects to login page if there isn't a valid user_token", %{conn: conn} do
      user_token = "invalid_token"
      session = conn |> put_session(:user_token, user_token) |> get_session()

      socket = %LiveView.Socket{
        endpoint: BrightWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = UserAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_user == nil
    end

    test "redirects to login page if there isn't a user_token", %{conn: conn} do
      session = conn |> get_session()

      socket = %LiveView.Socket{
        endpoint: BrightWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = UserAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_user == nil
    end
  end

  describe "on_mount: :redirect_if_user_is_authenticated" do
    test "redirects if there is an authenticated  user ", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)
      session = conn |> put_session(:user_token, user_token) |> get_session()

      assert {:halt, _updated_socket} =
               UserAuth.on_mount(
                 :redirect_if_user_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end

    test "doesn't redirect if there is no authenticated user", %{conn: conn} do
      session = conn |> get_session()

      assert {:cont, _updated_socket} =
               UserAuth.on_mount(
                 :redirect_if_user_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end
  end

  describe "on_mount: ensure_onboarding" do
    test "onboarding current_user based on a valid user_token", %{conn: conn, user: user} do
      onboarding = insert(:user_onboarding, user: user)
      user_token = Accounts.generate_user_session_token(user)
      session = conn |> put_session(:user_token, user_token) |> get_session()
      socket = %LiveView.Socket{}
      {:cont, socket} = UserAuth.on_mount(:mount_current_user, %{}, session, socket)

      {:cont, updated_socket} = UserAuth.on_mount(:ensure_onboarding, %{}, session, socket)

      assert updated_socket.assigns.current_user.user_onboardings.id == onboarding.id
    end

    test "redirects to onboarding page if there isn't a finish onboarding", %{
      conn: conn,
      user: user
    } do
      user_token = Accounts.generate_user_session_token(user)
      session = conn |> put_session(:user_token, user_token) |> get_session()

      socket = %LiveView.Socket{
        endpoint: BrightWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:cont, socket} = UserAuth.on_mount(:mount_current_user, %{}, session, socket)
      {:halt, updated_socket} = UserAuth.on_mount(:ensure_onboarding, %{}, session, socket)
      assert updated_socket.assigns.current_user.user_onboardings == nil
    end
  end

  describe "on_mount: redirect_if_onboarding_finished" do
    test "redirects when user already finished onboarding", %{conn: conn, user: user} do
      insert(:user_onboarding, user: user)
      user_token = Accounts.generate_user_session_token(user)
      session = conn |> put_session(:user_token, user_token) |> get_session()
      socket = %LiveView.Socket{}
      {:cont, socket} = UserAuth.on_mount(:mount_current_user, %{}, session, socket)

      assert {:halt, _updated_socket} =
               UserAuth.on_mount(
                 :redirect_if_onboarding_finished,
                 %{},
                 session,
                 socket
               )
    end

    test "doesn't redirect if there is no onboarding user", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)
      session = conn |> put_session(:user_token, user_token) |> get_session()
      socket = %LiveView.Socket{}
      {:cont, socket} = UserAuth.on_mount(:mount_current_user, %{}, session, socket)

      assert {:cont, _updated_socket} =
               UserAuth.on_mount(
                 :redirect_if_onboarding_finished,
                 %{},
                 session,
                 socket
               )
    end
  end

  describe "redirect_if_user_is_authenticated/2" do
    test "redirects if user is authenticated", %{conn: conn, user: user} do
      conn = conn |> assign(:current_user, user) |> UserAuth.redirect_if_user_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == ~p"/onboardings"
    end

    test "redirects mypage if user already finished onboardings", %{conn: conn, user: user} do
      insert(:user_onboarding, user: user)
      conn = conn |> assign(:current_user, user) |> UserAuth.redirect_if_user_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == ~p"/mypage"
    end

    test "does not redirect if user is not authenticated", %{conn: conn} do
      conn = UserAuth.redirect_if_user_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_user/2" do
    test "redirects if user is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> UserAuth.require_authenticated_user([])
      assert conn.halted

      assert redirected_to(conn) == ~p"/users/log_in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "ログインが必要です"
    end

    test "does not redirect if user is authenticated", %{conn: conn, user: user} do
      conn = conn |> assign(:current_user, user) |> UserAuth.require_authenticated_user([])
      refute conn.halted
      refute conn.status
    end
  end

  describe "redirect_if_onboarding_finished/2" do
    test "redirects mypage if user already finished onboardings", %{conn: conn, user: user} do
      insert(:user_onboarding, user: user)
      conn = conn |> assign(:current_user, user) |> UserAuth.redirect_if_onboarding_finished([])
      assert conn.halted
      assert redirected_to(conn) == ~p"/skill_up"
    end

    test "does not redirect if user is not authenticated", %{conn: conn, user: user} do
      conn = conn |> assign(:current_user, user) |> UserAuth.redirect_if_onboarding_finished([])

      refute conn.halted
      refute conn.status
    end
  end

  describe "require_onboarding/2" do
    test "redirects if user is not finish onboarding", %{conn: conn, user: user} do
      conn =
        conn |> assign(:current_user, user) |> fetch_flash() |> UserAuth.require_onboarding([])

      assert conn.halted

      assert redirected_to(conn) == ~p"/onboardings"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "オンボーディングが完了していません"
    end

    test "does not redirect if user is onboarding finish", %{conn: conn, user: user} do
      insert(:user_onboarding, user: user)
      conn = conn |> assign(:current_user, user) |> UserAuth.require_onboarding([])
      refute conn.halted
      refute conn.status
    end
  end
end
