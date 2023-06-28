defmodule BrightWeb.MypageLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index" do
    test "lists all mypages", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/mypages")

      assert html =~ "マイページ"
    end
  end
end
