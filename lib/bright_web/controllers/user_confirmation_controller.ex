defmodule BrightWeb.UserConfirmationController do
  use BrightWeb, :controller

  alias Bright.Accounts
  alias BrightWeb.UserAuth

  def confirm(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User confirmed successfully.")
        |> put_session(:user_return_to, ~p"/onboardings")
        |> UserAuth.log_in_user(user)

      :error ->
        case conn.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            conn
            |> redirect(to: ~p"/onboardings")

          %{} ->
            conn
            |> put_flash(:error, "User confirmation link is invalid or it has expired.")
            |> redirect(to: ~p"/")
        end
    end
  end
end
