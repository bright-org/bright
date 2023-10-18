defmodule BrightWeb.InitAssigns do
  @moduledoc """
  LiveViewに共通の`assigns`を適用

  refs:
  https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#on_mount/1-examples
  """

  import Phoenix.Component

  def fetch_current_request_path(conn, _opts) do
    Plug.Conn.put_session(conn, :current_request_path, conn.request_path)
  end

  def on_mount(:default, _params, session, socket) do
    {:cont,
     socket
     |> assign(:page_sub_title, nil)
     |> assign(:render_header?, true)
     |> assign(:current_request_path, session["current_request_path"])}
  end

  def on_mount(:without_header, _params, session, socket) do
    {:cont,
     socket
     |> assign(:render_header?, false)
     |> assign(:current_request_path, session["current_request_path"])}
  end
end
