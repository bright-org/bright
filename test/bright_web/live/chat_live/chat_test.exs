defmodule BrightWeb.ChatLive.ChatTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Show" do
    setup [:register_and_log_in_user]

    test "shows chats no data", %{
      conn: conn
    } do
      {:ok, _show_live, html} = live(conn, ~p"/recruits/chats")

      assert html =~ "チャット対象者がいません"

    end

  end
end
