defmodule BrightWeb.UserConfirmSubEmailControllerTest do
  use BrightWeb.ConnCase, async: true

  import Bright.Factory
  alias Bright.Repo
  alias Bright.Accounts
  alias Bright.Accounts.UserToken
  alias Bright.Accounts.UserSubEmail

  import Ecto.Query, warn: false

  setup [:register_and_log_in_user]

  setup %{conn: conn, user: user} do
    new_email = unique_user_email()

    token =
      extract_user_token(fn url ->
        Accounts.deliver_user_add_sub_email_instructions(
          user,
          new_email,
          url
        )
      end)

    %{conn: conn, user: user, token: token, new_email: new_email}
  end

  describe "GET /users/confirm_sub_email/:token" do
    test "adds user sub email", %{
      conn: conn,
      user: user,
      token: token,
      new_email: new_email
    } do
      conn = get(conn, ~p"/users/confirm_sub_email/#{token}")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "サブメールアドレスの追加に成功しました"
      assert redirected_to(conn) == ~p"/mypage"
      assert Repo.get_by(UserSubEmail, email: new_email)
      refute Repo.get_by(UserToken, user_id: user.id, context: "confirm_sub_email")
    end

    test "fails to add user sub email when email is not unique", %{
      conn: conn,
      user: user,
      token: token,
      new_email: new_email
    } do
      insert(:user, email: new_email)
      conn = get(conn, ~p"/users/confirm_sub_email/#{token}")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "リンクが無効であるか期限が切れています"
      assert redirected_to(conn) == ~p"/mypage"
      refute Repo.get_by(UserSubEmail, email: new_email)
      assert Repo.get_by(UserToken, user_id: user.id, context: "confirm_sub_email")
    end

    test "fails to add user sub email when email is not unique in sub email", %{
      conn: conn,
      user: user,
      token: token,
      new_email: new_email
    } do
      insert(:user_sub_email, email: new_email)
      conn = get(conn, ~p"/users/confirm_sub_email/#{token}")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "リンクが無効であるか期限が切れています"
      assert redirected_to(conn) == ~p"/mypage"
      refute Repo.get_by(UserSubEmail, user_id: user.id)
      assert Repo.get_by(UserToken, user_id: user.id, context: "confirm_sub_email")
    end

    test "fails to add user sub email when token is invalid", %{
      conn: conn,
      user: user,
      new_email: new_email
    } do
      conn = get(conn, ~p"/users/confirm_sub_email/invalid")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "リンクが無効であるか期限が切れています"
      assert redirected_to(conn) == ~p"/mypage"
      refute Repo.get_by(UserSubEmail, email: new_email)
      assert Repo.get_by(UserToken, user_id: user.id, context: "confirm_sub_email")
    end

    test "fails to add user sub email when token is expired", %{
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
                ^"confirm_sub_email"
        )
        |> Repo.update_all(
          set: [
            inserted_at:
              NaiveDateTime.utc_now()
              |> NaiveDateTime.add(-1 * 60 * 60 * 24)
          ]
        )

      conn = get(conn, ~p"/users/confirm_sub_email/#{token}")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "リンクが無効であるか期限が切れています"
      assert redirected_to(conn) == ~p"/mypage"
      refute Repo.get_by(UserSubEmail, email: new_email)
      assert Repo.get_by(UserToken, user_id: user.id, context: "confirm_sub_email")
    end

    test "fails to add user sub email when user already has 3 sub mails", %{
      conn: conn,
      user: user,
      token: token,
      new_email: new_email
    } do
      insert_list(3, :user_sub_email, user: user)
      conn = get(conn, ~p"/users/confirm_sub_email/#{token}")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "すでにサブメールアドレスが3つ登録されているため追加できません"
      assert redirected_to(conn) == ~p"/mypage"
      refute Repo.get_by(UserSubEmail, email: new_email)
      assert Repo.get_by(UserToken, user_id: user.id, context: "confirm_sub_email")
    end
  end
end
