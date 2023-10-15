defmodule BrightWeb.Admin.UserTokenLive.Index do
  use BrightWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:render_header?, false)
    |> assign(:current_user, nil)
    |> assign(:user_tokens, :ets.lookup(:token, "confirm"))
    |> then(&{:ok, &1})
  end
end
