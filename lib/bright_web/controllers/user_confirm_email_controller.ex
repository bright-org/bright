defmodule BrightWeb.UserConfirmEmailController do
  use BrightWeb, :controller

  alias Bright.Accounts

  # TODO: ZOHO 連携
  # 本番のみ
  def confirm(
        conn,
        %{"token" => token}
      ) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "メールアドレスの変更に成功しました")
        |> redirect(to: ~p"/mypage")

      :error ->
        conn
        |> put_flash(:error, "リンクが無効であるか期限が切れています")
        |> redirect(to: ~p"/mypage")
    end
  end
end
