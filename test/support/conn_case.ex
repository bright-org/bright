defmodule BrightWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use BrightWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate
  import Bright.Factory

  using do
    quote do
      # The default endpoint for testing
      @endpoint BrightWeb.Endpoint

      use BrightWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import BrightWeb.ConnCase
    end
  end

  setup tags do
    Bright.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

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
    token = Bright.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  @doc """
  Setup two_factor_auth_done.

  Set cookie and insert user two_factor_auth_done token.
  """
  def set_two_factor_auth_done(conn, user) do
    {token, user_token} = Bright.Accounts.UserToken.build_user_token(user, "two_factor_auth_done")

    insert(:user_token, user_token |> Map.from_struct())

    # 署名付き Cookie にしないといけないので以下で生成
    %{value: signed_token} =
      conn
      |> Map.replace!(:secret_key_base, BrightWeb.Endpoint.config(:secret_key_base))
      |> BrightWeb.UserAuth.write_2fa_auth_done_cookie(token)
      |> Plug.Conn.fetch_cookies()
      |> Map.fetch!(:resp_cookies)
      |> Map.fetch!("_bright_web_user_2fa_done")

    conn
    |> Phoenix.ConnTest.put_req_cookie("_bright_web_user_2fa_done", signed_token)
  end
end
