defmodule BrightWeb.UserConfirmationController do
  use BrightWeb, :controller

  alias Bright.Accounts
  alias BrightWeb.UserAuth

  def confirm(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, user} ->
        Accounts.try_create_zoho_contact(user)

        conn
        |> UserAuth.log_in_user(user)

      :error ->
        conn
        |> put_flash(:error, "リンクが無効であるか期限が切れています")
        |> redirect(to: ~p"/users/log_in")
    end
  end
end
