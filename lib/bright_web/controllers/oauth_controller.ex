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

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{}}} = conn, _params) do
    conn
    |> handle_callback()
  end

  # 未ログイン時
  defp handle_callback(
         %{
           assigns: %{
             current_user: nil,
             ueberauth_auth:
               %Ueberauth.Auth{
                 info: %Ueberauth.Auth.Info{name: name, email: email},
                 provider: provider,
                 uid: identifier
               } = ueberauth_auth
           }
         } = conn
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
            identifier: identifier,
            display_name: display_name(ueberauth_auth)
          })

        conn
        |> redirect(to: ~p"/users/register_social_account/#{token}")
    end
  end

  # ログイン時
  defp handle_callback(
         %{
           assigns: %{
             current_user: current_user,
             ueberauth_auth:
               %Ueberauth.Auth{
                 provider: provider,
                 uid: identifier
               } = ueberauth_auth
           }
         } = conn
       ) do
    case Accounts.link_social_account(current_user, %{
           provider: provider,
           identifier: identifier,
           display_name: display_name(ueberauth_auth)
         }) do
      {:ok, _user_social_auth} ->
        conn |> put_flash(:info, "連携しました") |> redirect(to: ~p"/mypage")

      {:error, %Ecto.Changeset{errors: [unique_provider_identifier: _reason]}} ->
        conn |> put_flash(:error, "すでに他のユーザーと連携済みです") |> redirect(to: ~p"/mypage")
    end
  end

  # プロバイダ毎の連携アカウントに対する表示名
  # Google: メールアドレス
  defp display_name(%Ueberauth.Auth{provider: :google, info: %Ueberauth.Auth.Info{email: email}}) do
    email
  end

  # NOTE: 取得できなくても表示されないだけなのでエラーにはせず nil とする
  defp display_name(_ueberauth_auth), do: nil

  # 連係解除
  def delete(%{assigns: %{current_user: current_user}} = conn, %{"provider" => provider}) do
    case Accounts.unlink_social_account(current_user, provider) do
      :cannot_unlink_last_one ->
        conn |> put_flash(:error, "SNS連携は少なくとも一つ必要なため連係解除できません") |> redirect(to: ~p"/mypage")

      _ ->
        conn |> put_flash(:info, "連係解除しました") |> redirect(to: ~p"/mypage")
    end
  end
end
