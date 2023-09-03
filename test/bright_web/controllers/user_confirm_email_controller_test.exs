defmodule BrightWeb.UserConfirmEmailControllerTest do
  use BrightWeb.ConnCase, async: true

  import Bright.Factory
  alias Bright.Repo
  alias Bright.Accounts
  alias Bright.Accounts.User
  alias Bright.Accounts.UserToken

  import Ecto.Query, warn: false

  setup [:register_and_log_in_user]

  setup %{conn: conn, user: user} do
    new_email = unique_user_email()

    token =
      extract_user_token(fn url ->
        Accounts.deliver_user_update_email_instructions(
          %{user | email: new_email},
          user.email,
          url
        )
      end)

    %{conn: conn, user: user, token: token, new_email: new_email}
  end

  describe "GET /users/confirm_email/:token" do
    test "updates user email", %{
      conn: conn,
      user: user,
      token: token,
      new_email: new_email
    } do
      conn = get(conn, ~p"/users/confirm_email/#{token}")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "メールアドレスの更新に成功しました"
      assert redirected_to(conn) == ~p"/mypage"
      assert Repo.get_by(User, email: new_email)
      refute Repo.get_by(UserToken, user_id: user.id, context: "change:#{user.email}")
    end

    test "fails to update user email when token is invalid", %{
      conn: conn,
      user: user,
      new_email: new_email
    } do
      conn = get(conn, ~p"/users/confirm_email/invalid")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "リンクが無効であるか期限が切れています"
      assert redirected_to(conn) == ~p"/mypage"
      refute Repo.get_by(User, email: new_email)
      assert Repo.get_by(UserToken, user_id: user.id, context: "change:#{user.email}")
    end

    test "fails to update user email when token is expired", %{
      conn: conn,
      user: user,
      token: token,
      new_email: new_email
    } do
      {1, nil} =
        from(u in UserToken,
          where:
            u.user_id == ^user.id and
              u.context ==
                ^"change:#{user.email}"
        )
        |> Repo.update_all(
          set: [
            inserted_at:
              NaiveDateTime.utc_now()
              |> NaiveDateTime.add(-1 * 60 * 60 * 24)
          ]
        )

      conn = get(conn, ~p"/users/confirm_email/#{token}")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "リンクが無効であるか期限が切れています"
      assert redirected_to(conn) == ~p"/mypage"
      refute Repo.get_by(User, email: new_email)
      assert Repo.get_by(UserToken, user_id: user.id, context: "change:#{user.email}")
    end
  end
end
