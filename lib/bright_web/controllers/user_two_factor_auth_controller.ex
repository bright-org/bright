defmodule BrightWeb.UserTwoFactorAuthController do
  use BrightWeb, :controller

  alias Bright.Accounts
  alias Bright.Accounts.User
  alias BrightWeb.UserAuth

  def create(conn, %{"user_2fa_code" => %{"code" => code, "token" => token}}) do
    Accounts.get_user_by_2fa_auth_session_token(token)
    |> case do
      %User{} = user ->
        validate_code(conn, user, code, token)

      _ ->
        conn
        |> put_flash(:error, "セッションの期限が切れました。再度ログインしてください。")
        |> redirect(to: ~p"/users/log_in")
    end
  end

  defp validate_code(conn, user, code, token) do
    user
    |> Accounts.user_2fa_code_valid?(code)
    |> case do
      true ->
        user_2fa_done_token = Accounts.generate_user_2fa_done_token(user)

        conn
        |> UserAuth.write_2fa_auth_done_cookie(user_2fa_done_token)
        |> put_flash(:info, "ログインしました")
        |> UserAuth.log_in_user(user)

      false ->
        conn
        |> put_flash(:error, "2段階認証コードが正しくないか期限切れです")
        |> redirect(to: ~p"/users/two_factor_auth/#{token}")
    end
  end
end
