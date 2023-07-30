defmodule BrightWeb.OAuthController do
  @moduledoc """
  Handle oauth2 using Ueberauth
  """

  use BrightWeb, :controller
  plug Ueberauth

  require Logger
  alias Ueberauth.Strategy.Helpers

  def request(conn, _params) do
    redirect(conn, to: Helpers.request_url(conn))
  end

  def callback(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{} = fail}} = conn, _params) do
    Logger.info(fail)

    conn
    |> put_flash(:error, "認証に失敗しました")
    |> redirect(to: ~p"/users/log_in")
  end

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, _params) do
    Logger.info(auth)

    conn
    |> put_flash(:info, "Succeed to authenticate!")
    |> redirect(to: "/")
  end
end
