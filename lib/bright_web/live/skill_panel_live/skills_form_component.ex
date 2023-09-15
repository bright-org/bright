defmodule BrightWeb.SkillPanelLive.SkillsFormComponent do
  use BrightWeb, :live_component

  import BrightWeb.SkillPanelLive.SkillPanelComponents, only: [score_mark_class: 2]

  alias Bright.SkillScores
  alias BrightWeb.BrightCoreComponents
  alias BrightWeb.CardLive.SkillCardComponent

  @shortcut_key_score %{
    "1" => :high,
    "2" => :middle,
    "3" => :low
  }

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <% # デザインは全て仮 %>
      <header class="mb-6">
        <h2 class="text-xl">
          <%= @skill_panel.name %>
          <span class="ml-2"><%= @skill_class.name %></span>
        </h2>

        <BrightCoreComponents.button class="mt-4" type="button" phx-click="submit" phx-target={@myself}>
          保存
        </BrightCoreComponents.button>
      </header>

      <section class="relative h-[60vh]">
        <div class="absolute top-0 right-0 bottom-0 left-0 overflow-y-auto">
          <div :for={skill_unit <- @skill_units} class="my-8">
            <div :for={skill_category <- skill_unit.skill_categories} class="my-4">
              <div class="font-bold">
                <p><%= skill_unit.name %></p>
                <p><%= skill_category.name %></p>
              </div>

              <%= for skill <- skill_category.skills do %>
                <% row = Map.get(@row_dict, skill.id) %>
                <% focus = row == @focus_row %>
                <% skill_score = @skill_score_dict[skill.id] %>

                <div id={"skill-#{row}-form"} class={[focus && "bg-brightGray-50", "flex justify-between border p-2 my-1"]}>
                  <p> <%= skill.name %> </p>
                  <div
                    class="flex-none flex justify-center gap-x-4 px-4"
                    phx-window-keydown={focus && "shortcut"}
                    phx-target={@myself}
                    phx-throttle="1000"
                    phx-value-skill_id={skill.id}
                  >
                    <label
                      class="block flex items-center"
                      phx-click="change"
                      phx-target={@myself}
                      phx-value-score="high"
                      phx-value-skill_id={skill.id}
                    >
                      <input
                        type="radio"
                        name={"score-#{row}-1"}
                        checked={skill_score.score == :high}
                        class="w-2 h-2 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600" />
                      <span class={[score_mark_class(:high, :green), "ml-1"]} />
                    </label>

                    <label
                      class="block flex items-center"
                      phx-click="change"
                      phx-target={@myself}
                      phx-value-score="middle"
                      phx-value-skill_id={skill.id}
                    >
                      <input
                        type="radio"
                        name={"score-#{row}-2"}
                        checked={skill_score.score == :middle}
                        class="w-2 h-2 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600" />
                      <span class={[score_mark_class(:middle, :green), "ml-1"]} />
                    </label>

                    <label
                      class="block flex items-center"
                      phx-click="change"
                      phx-target={@myself}
                      phx-value-score="low"
                      phx-value-skill_id={skill.id}
                    >
                      <input
                        type="radio"
                        name={"score-#{row}-3"}
                        checked={skill_score.score == :low}
                        class="w-2 h-2 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 hark:bg-gray-700 dark:border-gray-600" />
                      <span class={[score_mark_class(:low, :green), "ml-1"]} />
                    </label>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </section>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :focus_row, 1)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_skill_units()
     |> assign_row_dict()}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    %{
      user: user,
      skill_class_score: skill_class_score,
      skill_score_dict: skill_score_dict
    } = socket.assigns

    target_skill_scores = skill_score_dict |> Map.values() |> Enum.filter(& &1.changed)
    {:ok, _} = SkillScores.insert_or_update_skill_scores(target_skill_scores, user)

    # スキルクラスのレベル変更時に保有スキルカードの表示変更を通知
    maybe_update_skill_card_component(skill_class_score)

    {:noreply, push_patch(socket, to: socket.assigns.patch)}
  end

  def handle_event("change", %{"score" => score, "skill_id" => skill_id}, socket) do
    score = String.to_atom(score)
    skill_score = Map.get(socket.assigns.skill_score_dict, skill_id)
    row = Map.get(socket.assigns.row_dict, skill_id)

    {:noreply,
     socket
     |> update_by_score_change(skill_score, score)
     |> assign(:focus_row, row)}
  end

  def handle_event("shortcut", %{"key" => key, "skill_id" => skill_id}, socket)
      when key in ~w(1 2 3) do
    score = Map.get(@shortcut_key_score, key)
    skill_score = Map.get(socket.assigns.skill_score_dict, skill_id)

    {:noreply,
     socket
     |> update_by_score_change(skill_score, score)
     |> update(:focus_row, &Enum.min([&1 + 1, socket.assigns.num_skills]))
     |> push_scroll_to()}
  end

  def handle_event("shortcut", %{"key" => key}, socket) when key in ~w(ArrowDown Enter) do
    {:noreply,
     socket
     |> update(:focus_row, &Enum.min([&1 + 1, socket.assigns.num_skills]))
     |> push_scroll_to()}
  end

  def handle_event("shortcut", %{"key" => key}, socket) when key in ~w(ArrowUp) do
    {:noreply,
     socket
     |> update(:focus_row, &Enum.max([1, &1 - 1]))
     |> push_scroll_to()}
  end

  def handle_event("shortcut", _params, socket) do
    {:noreply, socket}
  end

  defp assign_skill_units(socket) do
    skill_units =
      socket.assigns.skill_class
      |> Bright.Repo.preload(skill_units: [skill_categories: [:skills]])
      |> Map.get(:skill_units)

    assign(socket, :skill_units, skill_units)
  end

  defp assign_row_dict(socket) do
    # 指定行をハイライトすることなどのためのUI便宜上の準備
    dict =
      socket.assigns.skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.flat_map(& &1.skills)
      |> Enum.with_index(1)
      |> Map.new(fn {skill, row} -> {skill.id, row} end)

    socket
    |> assign(:row_dict, dict)
    |> assign(:num_skills, Enum.count(dict))
  end

  defp update_by_score_change(socket, skill_score, score) do
    # 表示スコア更新
    # 永続化は全体一括のため、ここでは実施してない
    skill_score_dict =
      socket.assigns.skill_score_dict
      |> Map.put(skill_score.skill_id, %{skill_score | score: score, changed: true})

    assign(socket, :skill_score_dict, skill_score_dict)
  end

  defp maybe_update_skill_card_component(skill_class_score) do
    prev_level = skill_class_score.level
    skill_class_score = SkillScores.get_skill_class_score!(skill_class_score.id)
    new_level = skill_class_score.level

    if prev_level != new_level do
      send_update(SkillCardComponent, id: "skill_card", status: "level_changed")
    end
  end

  defp push_scroll_to(socket) do
    %{focus_row: row} = socket.assigns
    # キーショートカットによる入力時スクロール
    push_event(socket, "scroll-to-parent", %{target: "skill-#{row}-form"})
  end
end
