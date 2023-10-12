defmodule BrightWeb.UserConfirmSubEmailController do
  use BrightWeb, :controller

  alias Bright.Accounts
  alias Bright.Accounts.UserSubEmail

  def confirm(
        conn,
        %{"token" => token}
      ) do
    case Accounts.add_user_sub_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "サブメールアドレスの追加に成功しました")
        |> redirect(to: ~p"/mypage")

      :already_has_max_number_of_sub_emails ->
        conn
        |> put_flash(:error, "すでにサブメールアドレスが#{UserSubEmail.max_sub_email_num()}つ登録されているため追加できません")
        |> redirect(to: ~p"/mypage")

      :error ->
        conn
        |> put_flash(:error, "リンクが無効であるか期限が切れています")
        |> redirect(to: ~p"/mypage")
    end
  end
end
