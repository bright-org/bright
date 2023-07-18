defmodule BrightWeb.MyTeamLive do
  @moduledoc """
  マイチーム画面
  """
  use BrightWeb, :live_view
  import BrigntWeb.BrightModalComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
