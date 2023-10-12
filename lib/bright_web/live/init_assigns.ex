defmodule BrightWeb.InitAssigns do
  @moduledoc """
  LiveViewに共通の`assigns`を適用

  refs:
  https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#on_mount/1-examples
  """

  import Phoenix.Component

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> assign(:page_sub_title, nil)
     |> assign(:render_header?, true)}
  end

  def on_mount(:without_header, _params, _session, socket) do
    {:cont, assign(socket, :render_header?, false)}
  end
end
