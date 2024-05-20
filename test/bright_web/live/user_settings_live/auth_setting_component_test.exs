defmodule BrightWeb.UserSettingsLive.AuthSettingComponentTest do
  use BrightWeb.ConnCase

  alias Bright.Repo
  alias Bright.Accounts
  alias Bright.Accounts.UserToken
  alias Bright.Accounts.UserSubEmail
  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions

  describe "メール・パスワード" do
    setup [:register_and_log_in_user]

    test "shows each sections", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      assert lv |> has_element?("#email_form span", "メールアドレス")
      assert lv |> has_element?(~s{#email_form input[name="user[email]"][value="#{user.email}"]})

      assert lv |> has_element?("#sub_mail_section span", "サブアドレス")
      assert lv |> has_element?(~s{#sub_email_form input[name="user_sub_email[email]"][value=""]})

      refute lv
             |> has_element?(~s{#sub_mail_section input[name="sub_mail_1"][disabled]})

      refute lv |> has_element?("#delete_sub_email_button_1")

      assert lv |> has_element?("#password_form span", "現在のパスワード")

      assert lv
             |> has_element?(~s{#password_form input[type="password"][name="current_password"]})

      assert lv |> has_element?("#password_form span", "新しいパスワード")
      assert lv |> has_element?(~s{#password_form input[type="password"][name="user[password]"]})
      assert lv |> has_element?("#password_form span", "新しいパスワード（確認）")

      assert lv
             |> has_element?(
               ~s{#password_form input[type="password"][name="user[password_confirmation]"]}
             )
    end

    test "submits email form", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      new_email = "new_email@example.com"
      lv |> form("#email_form", user: %{email: new_email}) |> render_submit()

      assert_update_email_mail_sent(new_email)
      assert lv |> has_element?("#modal_flash", "本人確認メールを送信しました")

      # NOTE: Reset input form after submit
      assert lv |> has_element?(~s{#email_form input[name="user[email]"][value="#{user.email}"]})

      lv |> refute_redirected(~p"/mypage")
    end

    test "validates email form when email is not changed", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      lv |> form("#email_form", user: %{email: user.email}) |> render_submit()

      assert_no_email_sent()
      assert lv |> has_element?("#email_form .text-error", "変更されていません")
    end

    test "validates email form when submitted email is not unique", %{
      conn: conn
    } do
      other_user = insert(:user)
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      lv |> form("#email_form", user: %{email: other_user.email}) |> render_submit()

      assert_no_email_sent()
      assert lv |> has_element?("#email_form .text-error", "すでに使用されています")
    end

    test "validates email form when submitted email is not unique in user sub email", %{
      conn: conn
    } do
      user_sub_email = insert(:user_sub_email)

      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      lv |> form("#email_form", user: %{email: user_sub_email.email}) |> render_submit()

      assert_no_email_sent()
      assert lv |> has_element?("#email_form .text-error", "すでに使用されています")
    end

    test "validates email form when email is invalid format", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      lv |> form("#email_form", user: %{email: "invalid_format"}) |> render_change()
      assert lv |> has_element?("#email_form .text-error", "無効なフォーマットです")
    end

    test "show sub email delete button and add form when user has 1 sub email", %{
      conn: conn,
      user: user
    } do
      user_sub_email = insert(:user_sub_email, user: user)

      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      assert lv |> has_element?("#sub_mail_section span", "サブアドレス")

      assert lv
             |> has_element?(
               ~s{#sub_mail_section input[name="sub_mail_1"][value="#{user_sub_email.email}"][disabled]}
             )

      assert lv |> has_element?("#delete_sub_email_button_1")

      assert lv |> has_element?(~s{#sub_email_form input[name="user_sub_email[email]"][value=""]})
    end

    test "show sub email delete button and does not show add form when user has 3 sub email", %{
      conn: conn,
      user: user
    } do
      [user_sub_email1, user_sub_email2, user_sub_email3] =
        insert_list(3, :user_sub_email, user: user)

      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      assert lv |> has_element?("#sub_mail_section span", "サブアドレス")

      assert lv
             |> has_element?(
               ~s{#sub_mail_section input[name="sub_mail_1"][value="#{user_sub_email1.email}"][disabled]}
             )

      assert lv |> has_element?("#delete_sub_email_button_1")

      assert lv
             |> has_element?(
               ~s{#sub_mail_section input[name="sub_mail_2"][value="#{user_sub_email2.email}"][disabled]}
             )

      assert lv |> has_element?("#delete_sub_email_button_2")

      assert lv
             |> has_element?(
               ~s{#sub_mail_section input[name="sub_mail_3"][value="#{user_sub_email3.email}"][disabled]}
             )

      assert lv |> has_element?("#delete_sub_email_button_3")

      refute lv |> has_element?(~s{#sub_email_form input[name="user_sub_email[email]"][value=""]})
    end

    test "submits sub email form", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      new_email = unique_user_email()
      lv |> form("#sub_email_form", user_sub_email: %{email: new_email}) |> render_submit()

      assert_add_sub_email_mail_sent(new_email)
      assert lv |> has_element?("#modal_flash", "サブメールアドレス追加確認メールを送信しました")

      # NOTE: Reset input form after submit
      assert lv |> has_element?(~s{#sub_email_form input[name="user_sub_email[email]"][value=""]})

      lv |> refute_redirected(~p"/mypage")
    end

    test "clicks sub email delete button", %{conn: conn, user: user} do
      insert_list(3, :user_sub_email, user: user)

      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      assert lv |> has_element?("#delete_sub_email_button_1")
      assert lv |> has_element?("#delete_sub_email_button_2")
      assert lv |> has_element?("#delete_sub_email_button_3")
      refute lv |> has_element?(~s{#sub_email_form input[name="user_sub_email[email]"][value=""]})

      lv |> element("#delete_sub_email_button_2", "削除する") |> render_click()

      assert lv |> has_element?("#modal_flash", "サブメールアドレスを削除しました")

      assert Repo.aggregate(UserSubEmail, :count) == 2

      assert lv |> has_element?("#delete_sub_email_button_1")
      assert lv |> has_element?("#delete_sub_email_button_2")
      refute lv |> has_element?("#delete_sub_email_button_3")
      assert lv |> has_element?(~s{#sub_email_form input[name="user_sub_email[email]"][value=""]})
    end

    test "validates sub email form when sub email is invalid format", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      lv |> form("#sub_email_form", user_sub_email: %{email: "invalid_format"}) |> render_change()
      assert lv |> has_element?("#sub_email_form .text-error", "無効なフォーマットです")
    end

    test "validates email form when submitted sub email is not unique", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      lv |> form("#sub_email_form", user_sub_email: %{email: user.email}) |> render_submit()

      assert_no_email_sent()
      assert lv |> has_element?("#sub_email_form .text-error", "すでに使用されています")
    end

    test "validates email form when submitted sub email is not unique in sub email", %{conn: conn} do
      user_sub_email = insert(:user_sub_email)
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      lv
      |> form("#sub_email_form", user_sub_email: %{email: user_sub_email.email})
      |> render_submit()

      assert_no_email_sent()
      assert lv |> has_element?("#sub_email_form .text-error", "すでに使用されています")
    end

    test "submits password form", %{conn: conn, user: user, current_password: current_password} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      new_password = "password2"
      before_user_token = Repo.get_by(UserToken, user_id: user.id, context: "session")

      conn =
        lv
        |> form(
          "#password_form",
          %{
            current_password: current_password,
            user: %{
              password: new_password,
              password_confirmation: new_password
            }
          }
        )
        |> submit_form(conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "パスワードを変更しました"
      assert redirected_to(conn) == ~p"/mypage"
      assert Accounts.get_user_by_email_and_password(user.email, new_password)
      assert get_session(conn, :user_token)
      assert conn.resp_cookies["_bright_web_user"]
      assert conn.resp_cookies["_bright_web_user"].max_age == 60 * 60 * 24 * 60
      refute Repo.get(UserToken, before_user_token.id)
    end

    test "validates password form when current password is not matched", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()
      new_password = "password2"

      lv
      |> form(
        "#password_form",
        %{
          current_password: "invalid",
          user: %{
            password: new_password,
            password_confirmation: new_password
          }
        }
      )
      |> render_submit()

      assert lv |> has_element?("#password_form .text-error", "現在のパスワードと一致しません")
    end

    test "validates password form when invalid password and password confirmation", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      lv
      |> form(
        "#password_form",
        %{
          current_password: "invalid",
          user: %{
            password: "@",
            password_confirmation: "not match"
          }
        }
      )
      |> render_change()

      # NOTE: 「現在のパスワード」は on change ではバリデーションしない
      refute lv |> has_element?("#password_form .text-error", "現在のパスワードと一致しません")

      assert lv |> has_element?("#password_form .text-error", "数字を1文字以上含めてください")
      assert lv |> has_element?("#password_form .text-error", "英字を1文字以上含めてください")
      assert lv |> has_element?("#password_form .text-error", "8文字以上で入力してください")
      assert lv |> has_element?("#password_form .text-error", "パスワードが一致しません")
    end
  end

  describe "メール・パスワード when login sns login user" do
    setup [:register_and_log_in_social_account_user]

    test "shows only 「メールアドレス」 and 「サブアドレス」 and does not show password section", %{
      conn: conn,
      user: user
    } do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      assert lv |> has_element?("#email_form span", "メールアドレス")
      assert lv |> has_element?(~s{#email_form input[name="user[email]"][value="#{user.email}"]})

      assert lv |> has_element?("#sub_mail_section span", "サブアドレス")
      assert lv |> has_element?(~s{#sub_email_form input[name="user_sub_email[email]"][value=""]})

      # NOTE: SNS ID ログインのユーザーはパスワードを設定できないので表示しない
      refute lv |> has_element?("#password_form span", "現在のパスワード")

      refute lv
             |> has_element?(~s{#password_form input[type="password"][name="current_password"]})

      refute lv |> has_element?("#password_form span", "新しいパスワード")
      refute lv |> has_element?(~s{#password_form input[type="password"][name="user[password]"]})
      refute lv |> has_element?("#password_form span", "新しいパスワード（確認）")

      refute lv
             |> has_element?(
               ~s{#password_form input[type="password"][name="user[password_confirmation]"]}
             )
    end
  end
end
