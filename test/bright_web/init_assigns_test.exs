defmodule BrightWeb.InitAssignsTest do
  use ExUnit.Case
  use Plug.Test

  describe "fetch_current_request_path" do
    test "puts current request path to session" do
      conn =
        conn(:get, "/mypage", "")
        |> init_test_session(%{})
        |> BrightWeb.InitAssigns.fetch_current_request_path(nil)

      assert Plug.Conn.get_session(conn, :current_request_path) == "/mypage"

      conn =
        conn(:get, "/", "")
        |> init_test_session(%{})
        |> BrightWeb.InitAssigns.fetch_current_request_path(nil)

      assert Plug.Conn.get_session(conn, :current_request_path) == "/"
    end
  end
end
