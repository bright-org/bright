defmodule BrightWeb.UserConfirmationInstructionsLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory
  import Swoosh.TestAssertions

  alias Bright.Accounts
  alias Bright.Repo

  setup do
    %{user: insert(:user_not_confirmed)}
  end

  describe "Resend confirmation" do
    test "renders the resend confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/confirm")
      assert html =~ "確認メールが届かなかった方へ"
    end

    test "redirects log_in page when click 戻る button", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      lv
      |> element("a", "戻る")
      |> render_click()
      |> follow_redirect(conn, ~p"/users/log_in")
    end

    test "sends a new confirmation token", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "確認メールを再度送信しました"

      assert_email_sent(to: [{"", user.email}])

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "confirm"
    end

    test "sends a new confirmation token twice and only later token is valid", %{
      conn: conn,
      user: user
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      lv
      |> form("#resend_confirmation_form", user: %{email: user.email})
      |> render_submit()

      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      lv
      |> form("#resend_confirmation_form", user: %{email: user.email})
      |> render_submit()

      assert_email_sent(to: [{"", user.email}])

      assert Repo.aggregate(Accounts.UserToken, :count) == 1
    end

    test "does not send confirmation token if user is confirmed", %{conn: conn, user: user} do
      Repo.update!(Accounts.User.confirm_changeset(user))

      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "確認メールを再度送信しました"

      assert_no_email_sent()

      refute Repo.get_by(Accounts.UserToken, user_id: user.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "確認メールを再度送信しました"

      assert_no_email_sent()

      assert Repo.all(Accounts.UserToken) == []
    end
  end
end
