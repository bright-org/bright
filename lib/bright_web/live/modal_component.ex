defmodule BrightWeb.ModalComponent do
  @moduledoc """
  LiveComponent for modal.

  openの状態をもつ表示/非表示の制御を行う
  """

  use BrightWeb, :live_component

  import BrightWeb.BrightModalComponents

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.bright_modal
        id={"#{@id}_modal"}
        :if={@open}
        on_cancel={JS.push("close", target: @myself)}
        {@modal_styles}
        show
      >
        <%= render_slot(@inner_block) %>
      </.bright_modal>
    </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, :open, false)}
  end

  def update(%{open: true} = assigns, socket) do
    call_on_open(assigns)

    {:ok,
     socket
     |> assign(:on_close, Map.get(assigns, :on_close))
     |> assign(:open, true)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("close", _params, socket) do
    call_on_close(socket.assigns)
    {:noreply, assign(socket, :open, false)}
  end

  defp call_on_open(%{on_open: func}) do
    func.()
  end

  defp call_on_open(_), do: nil

  defp call_on_close(%{on_close: func}) do
    func.()
  end

  defp call_on_close(_), do: nil
end
