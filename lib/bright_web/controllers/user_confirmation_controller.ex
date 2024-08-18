defmodule BrightWeb.UserConfirmationController do
  use BrightWeb, :controller

  alias Bright.Accounts
  alias BrightWeb.UserAuth
  alias Bright.Utils.Env

  def confirm(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, user} ->
        if Env.prod?() do
          Accounts.try_create_zoho_contact(user)
        end

        conn
        |> UserAuth.log_in_user(user)

      :error ->
        conn
        |> put_flash(:error, "リンクが無効であるか期限が切れています")
        |> redirect(to: ~p"/users/log_in")
    end
  end
end
