defmodule BrightWeb.HelpMessageComponent do
  @moduledoc """
  LiveComponent for help message.
  """

  use BrightWeb, :live_component

  @impl true
  def render(%{open: false} = assigns) do
    ~H"""
    <div id={@id} />
    """
  end

  def render(assigns) do
    ~H"""
    <div id={@id} class="w-full">
      <div :if={@overlay} class="bg-pureGray-600/90 fixed inset-0 transition-opacity"></div>
      <div class="relative px-4 py-2 my-1 rounded text-sm bg-designer-dazzle leading-normal">
        <%= render_slot(@inner_block) %>

        <button
          class="absolute top-2 right-2"
          phx-click={JS.push("close", target: @myself) |> hide("##{@id}")}>
          <span class="material-icons text-white bg-brightGray-900 rounded-full !text-sm w-5 h-5 flex justify-center items-center">close</span>
        </button>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:open, true)
     |> assign(:overlay, false)}
  end

  @impl true
  def handle_event("open", _params, socket) do
    {:noreply, assign(socket, :open, true)}
  end

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, :open, false)}
  end
end
