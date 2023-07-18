defmodule BrightWeb.UserFinishResetPasswordLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Show" do
    test "show page", %{conn: conn} do
      {:ok, _show_live, html} = live(conn, ~p"/users/finish_reset_password")

      assert html =~ "パスワードリセットしました"
    end

    test "click ログインページへ", %{conn: conn} do
      {:ok, show_live, _html} = live(conn, ~p"/users/finish_reset_password")

      show_live
      |> element("a", "ログインページへ")
      |> render_click()
      |> follow_redirect(conn, ~p"/users/log_in")
    end
  end
end
