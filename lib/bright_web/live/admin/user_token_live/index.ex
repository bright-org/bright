defmodule BrightWeb.Admin.UserTokenLive.Index do
  use BrightWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :user_tokens, :ets.lookup(:token, "confirm"))}
  end
end
