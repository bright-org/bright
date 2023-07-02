defmodule BrightWeb.UserConfirmationControllerTest do
  use BrightWeb.ConnCase, async: true

  import Bright.Factory
  alias Bright.Accounts
  alias Bright.Repo
  alias Bright.Accounts.User
  alias Bright.Accounts.UserToken
  import Ecto.Query, warn: false

  setup do
    %{user: insert(:user_not_confirmed)}
  end

  describe "GET /users/confirm/:token" do
    test "token is invalid", %{conn: conn} do
      conn = get(conn, ~p"/users/confirm/invalid")
      assert html_response(conn, 302)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "User confirmation link is invalid or it has expired."
    end

    test "confirm user and logs the user in", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = get(conn, ~p"/users/confirm/#{token}")

      assert get_session(conn, :user_token)
      assert conn.resp_cookies["_bright_web_user"]
      assert redirected_to(conn) == ~p"/onboardings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "User confirmed successfully."
      assert Repo.get!(User, user.id).confirmed_at
      assert Repo.all(from u in UserToken, where: u.context == "confirm") == []

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ user.name
      assert response =~ user.email
      assert response =~ ~p"/users/settings"
      assert response =~ ~p"/users/log_out"
    end

    test "already confirmed", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = get(conn, ~p"/users/confirm/#{token}")

      # confirm again
      conn = get(conn, ~p"/users/confirm/#{token}")
      assert html_response(conn, 302)
      assert redirected_to(conn) == ~p"/onboardings"
    end
  end
end
