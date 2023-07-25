defmodule BrightWeb.SkillPanelLive.SkillScoreItemComponent do
  use BrightWeb, :live_component

  @shortcut_key_score %{
    "1" => :high,
    "2" => :middle,
    "3" => :low
  }

  @impl true
  def render(%{input: true} = assigns) do
    ~H"""
    <div
      id={@id}
      class="flex justify-center gap-x-4 px-4"
      phx-window-keydown="shortcut_key"
      phx-throttle="1000"
      phx-click-away="cancel_input"
      phx-target={@myself}
    >
      <label
        class="block flex items-center"
        phx-click="submit"
        phx-target={@myself}
        phx-value-score="high"
      >
        <input
          type="radio"
          name={"#{@id}-score"}
          checked={@skill_score_item.score == :high}
          class="w-2 h-2 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600" />
        <span class="h-4 w-4 rounded-full bg-brightGreen-600 inline-block ml-1"></span>
      </label>

      <label
        class="block flex items-center"
        phx-click="submit"
        phx-target={@myself}
        phx-value-score="middle"
      >
        <input
          type="radio"
          name={"#{@id}-score"}
          checked={@skill_score_item.score == :middle}
          class="w-2 h-2 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600" />
        <span class="h-0 w-0 border-solid border-t-0 border-r-8 border-l-8 border-transparent border-b-[14px] border-b-brightGreen-300 inline-block ml-1"></span>
      </label>

      <label
        class="block flex items-center"
        phx-click="submit"
        phx-target={@myself}
        phx-value-score="low"
      >
        <input
          type="radio"
          name={"#{@id}-score"}
          checked={@skill_score_item.score == :low}
          class="w-2 h-2 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 hark:bg-gray-700 dark:border-gray-600" />
        <span class="h-1 w-4 bg-brightGray-200 ml-1"></span>
      </label>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div id={@id} class="flex justify-center gap-x-4 px-4">
      <div class="flex items-center">
        <%= if @edit do %>
          <div
            class={["cursor-pointer", score_mark_class(@skill_score_item)]}
            phx-click="input"
            phx-target={@myself}
          />
        <% else %>
          <div class={score_mark_class(@skill_score_item)} />
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("input", _params, socket) do
    {:noreply, socket |> assign(input: true)}
  end

  def handle_event("cancel_input", _params, socket) do
    {:noreply, socket |> assign(input: false)}
  end

  def handle_event("submit", %{"score" => score}, socket) do
    notify_score_change(socket.assigns.skill_score_item, String.to_atom(score))

    {:noreply, socket |> assign(input: false)}
  end

  def handle_event("shortcut_key", %{"key" => key}, socket) when key in ~w(1 2 3) do
    score = Map.get(@shortcut_key_score, key)
    notify_score_change(socket.assigns.skill_score_item, score)

    if not socket.assigns.last_row? do
      send_update(__MODULE__, id: "skill-score-item-#{socket.assigns.row_number + 1}", input: true)
    end

    {:noreply, socket |> assign(input: false)}
  end

  def handle_event("shortcut_key", %{"key" => key}, socket) when key in ~w(ArrowDown Enter) do
    if not socket.assigns.last_row? do
      send_update(__MODULE__, id: "skill-score-item-#{socket.assigns.row_number + 1}", input: true)
    end

    {:noreply, socket |> assign(input: false)}
  end

  def handle_event("shortcut_key", %{"key" => key}, socket) when key in ~w(ArrowUp) do
    if not socket.assigns.first_row? do
      send_update(__MODULE__, id: "skill-score-item-#{socket.assigns.row_number - 1}", input: true)
    end

    {:noreply, socket |> assign(input: false)}
  end

  def handle_event("shortcut_key", _params, socket) do
    {:noreply, socket}
  end

  defp notify_score_change(%{score: current_score}, score) when current_score == score, do: nil

  defp notify_score_change(skill_score_item, score) do
    send(self(), {__MODULE__, {:score_change, skill_score_item, score}})
  end

  defp score_mark_class(skill_score_item) do
    skill_score_item.score
    |> case do
      :high ->
        "score-mark-high h-4 w-4 rounded-full bg-brightGreen-600"

      :middle ->
        "score-mark-middle h-0 w-0 border-solid border-t-0 border-r-8 border-l-8 border-transparent border-b-[14px] border-b-brightGreen-300"

      :low ->
        "score-mark-low h-1 w-4 bg-brightGray-200"
    end
  end
end
