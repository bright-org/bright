defmodule BrightWeb.SkillPanelLive.SkillScoreItemComponent do
  use BrightWeb, :live_component

  alias Bright.SkillScores

  @shortcut_key_score %{
    "1" => :high,
    "2" => :middle,
    "3" => :low
  }

  @impl true
  def render(%{edit: true} = assigns) do
    ~H"""
    <div
      id={@id}
      class="flex justify-center gap-x-4 px-4"
      phx-window-keydown="shortcut_key"
      phx-throttle="1000"
      phx-click-away="cancel_edit"
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

  def render(%{edit: false} = assigns) do
    ~H"""
    <div id={@id} class="flex justify-center gap-x-4 px-4">
      <div class="flex items-center">
        <div
          class={["cursor-pointer", score_mark_class(@skill_score_item)]}
          phx-click="edit"
          phx-target={@myself}
        />
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> create_skill_score_item_if_not_existing()}
  end

  @impl true
  def handle_event("edit", _params, socket) do
    {:noreply,
     socket
     |> assign(edit: true)
     |> create_skill_score_item_if_not_existing()}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply, socket |> assign(edit: false)}
  end

  def handle_event("submit", %{"score" => score}, socket) do
    skill_score_item = update_skill_score_item_score(socket.assigns.skill_score_item, score)

    {:noreply,
     socket
     |> assign(skill_score_item: skill_score_item, edit: false)}
  end

  def handle_event("shortcut_key", %{"key" => key}, socket) when key in ~w(1 2 3) do
    score = Map.get(@shortcut_key_score, key)
    skill_score_item = update_skill_score_item_score(socket.assigns.skill_score_item, score)

    if not socket.assigns.last_row? do
      send_update(__MODULE__, id: "skill-score-item-#{socket.assigns.row_number + 1}", edit: true)
    end

    {:noreply,
     socket
     |> assign(skill_score_item: skill_score_item, edit: false)}
  end

  def handle_event("shortcut_key", %{"key" => key}, socket) when key in ~w(ArrowDown Enter) do
    if not socket.assigns.last_row? do
      send_update(__MODULE__, id: "skill-score-item-#{socket.assigns.row_number + 1}", edit: true)
    end

    {:noreply, socket |> assign(edit: false)}
  end

  def handle_event("shortcut_key", %{"key" => key}, socket) when key in ~w(ArrowUp) do
    if not socket.assigns.first_row? do
      send_update(__MODULE__, id: "skill-score-item-#{socket.assigns.row_number - 1}", edit: true)
    end

    {:noreply, socket |> assign(edit: false)}
  end

  def handle_event("shortcut_key", _params, socket) do
    {:noreply, socket}
  end

  defp create_skill_score_item_if_not_existing(
         %{assigns: %{skill_score_item: nil, edit: true}} = socket
       ) do
    {:ok, skill_score_item} =
      SkillScores.create_skill_score_item(%{
        skill_id: socket.assigns.skill.id,
        skill_score_id: socket.assigns.skill_score.id,
        score: :low
      })

    socket |> assign(skill_score_item: skill_score_item)
  end

  defp create_skill_score_item_if_not_existing(socket), do: socket

  defp update_skill_score_item_score(skill_score_item, score) do
    {:ok, skill_score_item} =
      SkillScores.update_skill_score_item(skill_score_item, %{score: score})

    skill_score_item
  end

  defp score_mark_class(nil) do
    "score-mark-none h-1 w-4 bg-brightGray-200"
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
