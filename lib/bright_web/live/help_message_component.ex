defmodule BrightWeb.HelpMessageComponent do
  @moduledoc """
  LiveComponent for help message.
  """

  use BrightWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :open, true)}
  end

  @impl true
  def render(%{open: false} = assigns) do
    ~H"""
    <div id={@id} />
    """
  end

  def render(assigns) do
    ~H"""
    <div id={@id} class="relative px-4 py-2 my-1 rounded w-fit text-xs bg-designer-dazzle leading-normal">
      <%= render_slot(@inner_block) %>

      <div class="flex gap-4 justify-center pt-2">
        <button
          id={good_button_id(@id)}
          type="button"
          class="bg-brightGray-900 border border-brightGray-900 font-bold p-1 rounded text-white w-48"
          phx-click={JS.push("good", target: @myself) |> hide("##{@id}")}>
          この説明は分かりやすい
        </button>
        <button
          id={bad_button_id(@id)}
          type="button"
          class="bg-white border border-brightGray-900 font-bold p-1 rounded text-brightGray-900 w-24"
          phx-click={JS.push("bad", target: @myself) |> hide("##{@id}")}>
          わかりにくい
        </button>
      </div>

      <button
        class="absolute top-2 right-2"
        phx-click={JS.push("close", target: @myself) |> hide("##{@id}")}>
        <span class="material-icons text-white bg-brightGray-900 rounded-full !text-sm w-5 h-5 flex justify-center items-center">close</span>
      </button>
    </div>
    """
  end

  @impl true
  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, :open, false)}
  end

  def handle_event("good", _params, socket) do
    # TODO: 所定の処理を追加
    {:noreply, assign(socket, :open, false)}
  end

  def handle_event("bad", _params, socket) do
    # TODO: 所定の処理を追加
    {:noreply, assign(socket, :open, false)}
  end

  # NOTE:
  #   idはGAイベントトラッキング対象、変更の際は確認と共有必要
  defp good_button_id(id), do: "btn-#{id}-good"

  defp bad_button_id(id), do: "btn-#{id}-bad"
end
