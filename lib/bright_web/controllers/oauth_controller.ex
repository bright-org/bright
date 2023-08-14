defmodule BrightWeb.OAuthController do
  @moduledoc """
  Handle oauth2 using Ueberauth
  """

  use BrightWeb, :controller
  plug Ueberauth

  require Logger
  alias BrightWeb.UserAuth
  alias Bright.Accounts
  alias Bright.Accounts.User

  # NOTE: plug Ueberauth の処理中に指定された provider パラメータに対応する各 Strategy の実装に従ってリダイレクトが行われるのでコントローラー側は空でよい
  def request(_conn, _params), do: nil

  def callback(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{} = fail}} = conn, _params) do
    Logger.warning(inspect(fail))

    conn
    |> put_flash(:error, "認証に失敗しました")
    |> redirect(to: ~p"/users/register")
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
