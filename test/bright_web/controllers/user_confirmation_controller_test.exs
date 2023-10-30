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
               "リンクが無効であるか期限が切れています"

      assert redirected_to(conn) == ~p"/users/log_in"
    end

    test "token is already expired", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {1, nil} =
        Repo.update_all(
          UserToken,
          set: [
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.add(-1 * 60 * 60 * 24)
          ]
        )

      conn = get(conn, ~p"/users/confirm/#{token}")
      assert html_response(conn, 302)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "リンクが無効であるか期限が切れています"

      assert redirected_to(conn) == ~p"/users/log_in"
    end

    test "confirm user and logs the user in", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = get(conn, ~p"/users/confirm/#{token}")

      assert get_session(conn, :user_token)
      assert conn.resp_cookies["_bright_web_user"]
      assert redirected_to(conn) == ~p"/onboardings/welcome"
      assert Repo.get!(User, user.id).confirmed_at
      assert Repo.all(from(u in UserToken, where: u.context == "confirm")) == []
    end

    test "confirms 2 times", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = get(conn, ~p"/users/confirm/#{token}")

      # confirm again
      conn = conn |> get(~p"/users/confirm/#{token}")
      assert html_response(conn, 302)
      assert redirected_to(conn) == ~p"/onboardings/welcome"
    end

    test "confirms, logs out and confirms again", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = get(conn, ~p"/users/confirm/#{token}") |> delete(~p"/users/log_out")

      # confirm again
      conn = get(conn, ~p"/users/confirm/#{token}")
      assert html_response(conn, 302)
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "リンクが無効であるか期限が切れています"
      assert redirected_to(conn) == ~p"/users/log_in"
    end

    test "confirms a user while logs in other user", %{conn: conn, user: user} do
      %{conn: conn, user: _other_user} = register_and_log_in_user(%{conn: conn})

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = get(conn, ~p"/users/confirm/#{token}")

      assert html_response(conn, 302)
      assert redirected_to(conn) == ~p"/mypage"
    end
  end
end
