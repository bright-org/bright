defmodule BrightWeb.TeamMyTeamLive do
  use BrightWeb, :live_view

  def render(assigns) do
    ~H"""
    <p>My Team</p>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
