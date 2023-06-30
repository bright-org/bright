defmodule BrightWeb.MyTeam do
  @moduledoc """
  マイチーム画面
  """
  use BrightWeb, :live_view

  def render(assigns) do
    ~H"""
    マイチーム画面
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
