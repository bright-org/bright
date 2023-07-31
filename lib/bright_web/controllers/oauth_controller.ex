defmodule BrightWeb.OAuthController do
  @moduledoc """
  Handle oauth2 using Ueberauth
  """

  use BrightWeb, :controller
  plug Ueberauth

  require Logger
  alias Ueberauth.Strategy.Helpers
  alias BrightWeb.UserAuth
  alias Bright.Accounts
  alias Bright.Accounts.User

  def request(conn, _params) do
    redirect(conn, to: Helpers.request_url(conn))
  end

  def callback(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{} = fail}} = conn, _params) do
    Logger.info(fail)

    conn
    |> put_flash(:error, "認証に失敗しました")
    |> redirect(to: ~p"/users/log_in")
  end

  def callback(
        %{
          assigns: %{
            ueberauth_auth: %Ueberauth.Auth{
              info: %Ueberauth.Auth.Info{name: name, email: email},
              provider: provider,
              uid: identifier
            }
          }
        } = conn,
        _params
      ) do
    case Accounts.get_user_by_provider_and_identifier(provider, identifier) do
      %User{confirmed_at: nil} ->
        conn
        |> put_flash(:error, "メールアドレス未確認ユーザーです。メールを確認して確認済みにしてください。")
        |> redirect(to: ~p"/users/log_in")

      %User{} = user ->
        conn
        |> put_flash(:info, "ログインしました")
        |> UserAuth.log_in_user(user)

      _ ->
        token =
          Accounts.generate_social_identifier_token(%{
            name: name,
            email: email,
            provider: provider,
            identifier: identifier
          })

        conn
        |> redirect(to: ~p"/users/register_social_account/#{token}")
    end
  end
end
