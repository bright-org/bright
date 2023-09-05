defmodule BrightWeb.UserSettingsLive.AuthSettingComponentTest do
  use BrightWeb.ConnCase

  alias Bright.Repo
  alias Bright.Accounts
  alias Bright.Accounts.UserToken
  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions

  describe "メール・パスワード" do
    setup [:register_and_log_in_user]

    test "shows each sections", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      assert lv |> has_element?("#email_form span", "メールアドレス")
      assert lv |> has_element?(~s{#email_form input[name="user[email]"][value="#{user.email}"]})

      assert lv |> has_element?("span", "サブアドレス")
      assert lv |> has_element?(~s{input[type="text"][disabled]})

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

    test "submits email form", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      new_email = "new_email@example.com"
      lv |> form("#email_form", user: %{email: new_email}) |> render_submit()

      assert_update_email_mail_sent(new_email)
      assert lv |> has_element?("#modal_flash", "本人確認メールを送信しましたご確認ください")
      lv |> refute_redirected(~p"/mypage")
    end

    test "validates email form when email is not changed", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      lv |> form("#email_form", user: %{email: user.email}) |> render_submit()

      assert_no_email_sent()
      assert lv |> has_element?("#email_form .text-error", "変更されていません")
    end

    test "validates email form when email is invalid format", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "メール・パスワード") |> render_click()

      lv |> form("#email_form", user: %{email: "invalid_format"}) |> render_change()
      assert lv |> has_element?("#email_form .text-error", "無効なフォーマットです")
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

      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "パスワードを更新しました"
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

      assert lv |> has_element?("span", "サブアドレス")
      assert lv |> has_element?(~s{input[type="text"][disabled]})

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
