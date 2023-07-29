defmodule BrightWeb.MypageLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  describe "Index" do
    setup [:register_and_log_in_user]

    test "lists all mypages", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/mypage")

      assert html =~ "マイページ"
    end
  end
end
