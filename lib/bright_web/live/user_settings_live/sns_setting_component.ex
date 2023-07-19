defmodule BrightWeb.UserSettingsLive.SnsSettingComponent do
  use BrightWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      SNS連携
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
