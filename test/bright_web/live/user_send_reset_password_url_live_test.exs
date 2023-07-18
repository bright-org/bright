defmodule BrightWeb.UserSendResetPasswordUrlLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Show" do
    test "show page", %{conn: conn} do
      {:ok, _show_live, html} = live(conn, ~p"/users/send_reset_password_url")

      assert html =~ "登録しているメールアドレスにパスワード再設定用のリンクを送信しました"
    end
  end
end
