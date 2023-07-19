defmodule BrightWeb.UserSettingsLive.JobSettingComponent do
  use BrightWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      求職
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
