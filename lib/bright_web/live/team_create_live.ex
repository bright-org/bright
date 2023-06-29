defmodule BrightWeb.TeamCreateLive do
  use BrightWeb, :live_view

  def render(assigns) do
    ~H"""
    <p>Create New Team</p>
    """
  end

  def mount(_params, _session, socket) do
    # TODO mount修正
    {:ok, socket}
  end
end
