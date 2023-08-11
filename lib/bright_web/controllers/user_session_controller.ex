defmodule BrightWeb.UserSessionController do
  use BrightWeb, :controller

  alias Bright.Accounts
  alias BrightWeb.UserAuth

  # TODO: _action をハックして二段階認証をスキップされないように別コントローラーにする
  def create(conn, %{"_action" => "password_updated", "user" => user_params} = _params) do
    info = "Password updated successfully!"
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, ~p"/users/settings")
    else
      redirect_log_in_page(conn, email)
    end
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      if UserAuth.valid_2fa_auth_done_cookie_exists?(conn, user) do
        conn
        |> put_flash(:info, "ログインしました")
        |> UserAuth.log_in_user(user)
      else
        token = Accounts.setup_user_2fa_auth(user)

        conn
        |> redirect(to: ~p"/users/two_factor_auth/#{token}")
      end
    else
      redirect_log_in_page(conn, email)
    end
  end

  defp redirect_log_in_page(conn, email) do
    # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
    conn
    |> put_flash(:error, "Invalid email or password")
    |> put_flash(:email, String.slice(email, 0, 160))
    |> redirect(to: ~p"/users/log_in")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "ログアウトしました")
    |> UserAuth.log_out_user()
  end
end
