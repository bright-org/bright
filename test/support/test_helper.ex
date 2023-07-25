defmodule Bright.TestHelper do
  @moduledoc """
  Test helpers.
  """

  import Bright.Factory
  import Plug.Conn
  import Phoenix.ConnTest

  alias Bright.Accounts
  alias BrightWeb.Endpoint
  alias BrightWeb.UserAuth

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = insert(:user)
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Accounts.generate_user_session_token(user)

    conn
    |> init_test_session(%{})
    |> put_session(:user_token, token)
  end

  @doc """
  Setup two_factor_auth_done.

  Set cookie and insert user two_factor_auth_done token.
  """
  def set_two_factor_auth_done(conn, user) do
    {token, user_token} = Accounts.UserToken.build_user_token(user, "two_factor_auth_done")

    insert(:user_token, user_token |> Map.from_struct())

    # 署名付き Cookie にしないといけないので以下で生成
    %{value: signed_token} =
      conn
      |> Map.replace!(:secret_key_base, Endpoint.config(:secret_key_base))
      |> UserAuth.write_2fa_auth_done_cookie(token)
      |> fetch_cookies()
      |> Map.fetch!(:resp_cookies)
      |> Map.fetch!("_bright_web_user_2fa_done")

    conn
    |> put_req_cookie("_bright_web_user_2fa_done", signed_token)
  end
end
