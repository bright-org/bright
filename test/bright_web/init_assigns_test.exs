defmodule BrightWeb.InitAssignsTest do
  use ExUnit.Case
  use Plug.Test

  describe "fetch_current_request_path/2" do
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

  describe "on_mount/4" do
    test "assigns initial value" do
      session =
        conn(:get, "/", "")
        |> init_test_session(%{})
        |> put_session(:current_request_path, "/")
        |> get_session()

      {:cont, socket} =
        BrightWeb.InitAssigns.on_mount(:default, nil, session, %Phoenix.LiveView.Socket{})

      assert socket.assigns.page_sub_title == nil
      assert socket.assigns.render_header? == true
      assert socket.assigns.current_request_path == "/"
    end

    test "assigns initial value when without_header" do
      session =
        conn(:get, "/", "")
        |> init_test_session(%{})
        |> put_session(:current_request_path, "/")
        |> get_session()

      {:cont, socket} =
        BrightWeb.InitAssigns.on_mount(:without_header, nil, session, %Phoenix.LiveView.Socket{})

      assert socket.assigns[:page_sub_title] == nil
      assert socket.assigns.render_header? == false
      assert socket.assigns.current_request_path == "/"
    end
  end
end
