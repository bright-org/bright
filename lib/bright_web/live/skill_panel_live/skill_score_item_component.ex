defmodule BrightWeb.SkillPanelLive.SkillScoreItemComponent do
  use BrightWeb, :live_component

  alias Bright.SkillScores

  @impl true
  def render(%{open: true} = assigns) do
    ~H"""
    <div id={@id} class="flex justify-center gap-x-4 px-4">
      <label
        class="block flex items-center"
        phx-click="submit"
        phx-target={@myself}
        phx-value-score="high">
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
        phx-value-score="middle">
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
        phx-value-score="low">
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

  def render(%{open: false} = assigns) do
    ~H"""
    <div id={@id} class="flex justify-center gap-x-4 px-4">
      <div class="flex items-center">
        <div
          class={["cursor-pointer", score_mark_class(@skill_score_item)]}
          phx-click="open"
          phx-target={@myself}
        />
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("open", _params, socket) do
    {:noreply,
     socket
     |> create_skill_score_item_if_not_exist()
     |> assign(open: true)}
  end

  def handle_event("submit", %{"score" => score}, socket) do
    skill_score_item =
      socket.assigns.skill_score_item
      |> SkillScores.update_skill_score_item(%{score: score})
      |> elem(1)

    {:noreply,
     socket
     |> assign(skill_score_item: skill_score_item, open: false)}
  end

  defp create_skill_score_item_if_not_exist(%{assigns: %{skill_score_item: nil}} = socket) do
    skill_score_item =
      SkillScores.create_skill_score_item(%{
        skill_id: socket.assigns.skill.id,
        skill_score_id: socket.assigns.skill_score.id,
        score: :low
      })
      |> elem(1)

    socket |> assign(skill_score_item: skill_score_item)
  end

  defp create_skill_score_item_if_not_exist(socket), do: socket

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
