defmodule BrightWeb.UserAuth do
  @moduledoc false

  use BrightWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Bright.Accounts
  alias Bright.Repo

  # Make the cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @cookie_key "_bright_web_user"
  @cookie_options [sign: true, max_age: @max_age, same_site: "Lax"]

  # Two factor auth cookie
  @user_2fa_max_age 60 * 60 * 24 * 60
  @user_2fa_cookie_key "_bright_web_user_2fa_done"
  @user_2fa_cookie_options [sign: true, max_age: @user_2fa_max_age, same_site: "Lax"]

  @doc """
  Write two factor auth done cookie.
  """
  def write_2fa_auth_done_cookie(conn, token) do
    put_resp_cookie(conn, @user_2fa_cookie_key, token, @user_2fa_cookie_options)
  end

  def valid_2fa_auth_done_cookie_exists?(conn, user) do
    conn = fetch_cookies(conn, signed: [@user_2fa_cookie_key])

    token = conn.cookies[@user_2fa_cookie_key]

    if is_nil(token) do
      false
    else
      user_by_token = Accounts.get_user_by_2fa_done_token(token)
      !is_nil(user_by_token) && user_by_token.id == user.id
    end
  end

  @doc """
  Logs the user in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_user(conn, user, user_return_to \\ nil) do
    token = Accounts.generate_user_session_token(user)

    conn
    |> renew_session()
    |> put_token_in_session(token)
    |> write_cookie(token)
    |> redirect(to: user_return_to || log_in_redirect_path(user))
  end

  def log_in_redirect_path(user) do
    if Accounts.onboarding_finished?(user) do
      ~p"/mypage"
    else
      ~p"/onboardings/welcome"
    end
  end

  defp write_cookie(conn, token) do
    put_resp_cookie(conn, @cookie_key, token, @cookie_options)
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_user(conn) do
    user_token = get_session(conn, :user_token)
    user_token && Accounts.delete_user_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      BrightWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@cookie_key)
    |> redirect(to: ~p"/users/log_in")
  end

  @doc """
  Authenticates the user by looking into the session
  and cookie token.
  """
  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)

    user =
      (user_token && Accounts.get_user_by_session_token(user_token))
      |> Repo.preload([:user_profile, :user_onboardings])

    assign(conn, :current_user, user)
  end

  defp ensure_user_token(conn) do
    if token = get_session(conn, :user_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@cookie_key])

      if token = conn.cookies[@cookie_key] do
        {token, put_token_in_session(conn, token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Handles mounting and authenticating the current_user in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_user` - Assigns current_user
      to socket assigns based on user_token, or nil if
      there's no user_token or no matching user.

    * `:ensure_authenticated` - Authenticates the user from the session,
      and assigns the current_user to socket assigns based
      on user_token.
      Redirects to login page if there's no logged user.

    * `:redirect_if_user_is_authenticated` - Authenticates the user from the session.
      Redirects to signed_in_path if there's a logged user.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the current_user:

      defmodule BrightWeb.PageLive do
        use BrightWeb, :live_view

        on_mount {BrightWeb.UserAuth, :mount_current_user}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{BrightWeb.UserAuth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "ログインが必要です")
        |> Phoenix.LiveView.redirect(to: ~p"/users/log_in")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)
    current_user = socket.assigns.current_user

    if current_user do
      {:halt, Phoenix.LiveView.redirect(socket, to: log_in_redirect_path(current_user))}
    else
      {:cont, socket}
    end
  end

  def on_mount(:ensure_onboarding, _params, _session, socket) do
    if socket.assigns.current_user.user_onboardings do
      {:cont, socket}
    else
      socket
      |> Phoenix.LiveView.put_flash(:error, "オンボーディングが完了していません")
      |> Phoenix.LiveView.redirect(to: ~p"/onboardings/welcome")
      |> then(&{:halt, &1})
    end
  end

  def on_mount(:redirect_if_onboarding_finished, _params, _session, socket) do
    if socket.assigns.current_user.user_onboardings do
      socket
      |> Phoenix.LiveView.redirect(to: ~p"/skill_up")
      |> then(&{:halt, &1})
    else
      {:cont, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user_token = session["user_token"] do
        Accounts.get_user_by_session_token(user_token)
        |> Repo.preload([:user_profile, :user_onboardings])
      end
    end)
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    current_user = conn.assigns[:current_user]

    if current_user do
      conn
      |> put_flash(:error, "ログイン中はアクセスできません")
      |> redirect(to: log_in_redirect_path(current_user))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "ログインが必要です")
      |> redirect(to: ~p"/users/log_in")
      |> halt()
    end
  end

  def require_onboarding(conn, _ops) do
    if Accounts.onboarding_finished?(conn.assigns[:current_user]) do
      conn
    else
      conn
      |> put_flash(:error, "オンボーディングが完了していません")
      |> redirect(to: ~p"/onboardings/welcome")
      |> halt()
    end
  end

  def redirect_if_onboarding_finished(conn, _ops) do
    if Accounts.onboarding_finished?(conn.assigns[:current_user]) do
      conn
      |> redirect(to: ~p"/skill_up")
      |> halt()
    else
      conn
    end
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  end
end
