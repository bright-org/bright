defmodule BrightWeb.UserPasswordResetController do
  use BrightWeb, :controller

  alias Bright.Accounts
  alias BrightWeb.UserAuth

  def create(
        conn,
        %{
          "current_password" => current_password,
          "user" =>
            %{"password" => _password, "password_confirmation" => _password_confirmation} =
              user_params
        }
      ) do
    case Accounts.update_user_password(conn.assigns.current_user, current_password, user_params) do
      {:ok, user} ->
        # NOTE: パスワード更新時はセッションを作り替えるので再ログイン（phx.gen.auth デフォルトの挙動）
        conn
        |> put_flash(:info, "パスワードを更新しました")
        |> UserAuth.log_in_user(user, ~p"/mypage")

      _ ->
        conn
        |> put_flash(:error, "パスワードの更新に失敗しました")
        |> redirect(to: ~p"/mypage")
    end
  end
end
