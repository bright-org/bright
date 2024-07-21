defmodule BrightWeb.SkillPanelLive.SkillsCardComponent do
  # スキルパネル画面 スキル一覧をカード形式で表示するコンポーネント
  # （スキルスコア入力に関しては、LiveViewで行いこちらでは制御しない）

  use BrightWeb, :live_component

  import BrightWeb.SkillPanelLive.SkillsComponents

  alias BrightWeb.BrightCoreComponents

  # スコアと対応するHTML class属性
  @score_mark_class %{
    "high" =>
      "score-mark-high bg-white border border-brightGray-300 flex cursor-pointer h-8 items-center justify-center rounded w-8 before:content-[''] before:h-4 before:w-4 before:rounded-full before:bg-brightGray-300 before:block peer-checked:bg-brightGreen-300 peer-checked:border-brightGreen-300 peer-checked:before:bg-white hover:filter hover:brightness-[80%]",
    "middle" =>
      "score-mark-middle bg-white border border-brightGray-300 flex cursor-pointer h-8 items-center justify-center rounded w-8 before:content-[''] before:h-0 before:w-0 before:border-solid before:border-t-0 before:border-r-8 before:border-l-8 before:border-transparent before:border-b-[14px] before:border-b-brightGray-300 peer-checked:bg-brightGreen-300 peer-checked:border-brightGreen-300 peer-checked:before:border-b-white hover:filter hover:brightness-[80%]",
    "low" =>
      "score-mark-low bg-white border border-brightGray-300 flex cursor-pointer h-8 items-center justify-center rounded w-8 before:content-[''] before:block before:w-4 before:h-1 before:bg-brightGray-300 peer-checked:bg-brightGreen-300 peer-checked:border-brightGreen-300 peer-checked:before:bg-white hover:filter hover:brightness-[80%]"
  }

  def render(assigns) do
    ~H"""
    <div id={@id} class="mt-0 lg:mt-4">
      <BrightCoreComponents.flash_group flash={@inner_flash} />

      <div class="px-6 mt-4 lg:mt-8">
      <div class="flex flex-col gap-2">
        <%= for {skill_unit, index} <- Enum.with_index(@skill_units) do %>
          <div id={"unit-#{index + 1}"} class="border p-4 bg-brightGray-50">
            <div id={"unit-#{index + 1}-sp"} class="flex gap-x-4">
              <span class="text-lg"><%= skill_unit.name %></span>
            </div>
            <div class="flex flex-wrap gap-2">
              <%= for skill_category <- skill_unit.skill_categories do %>
                <div class="border-2 border-black p-4 m-4">
                    <%= skill_category.name %>
                  <div class="flex flex-wrap">
                    <%= for skill <- skill_category.skills do %>

                      <% skill_score = @current_skill_score_dict[skill.id] %>
                      <% current_skill = Map.get(@current_skill_dict, skill.trace_id, %{}) %>
                      <% current_skill_score = Map.get(@current_skill_score_dict, Map.get(current_skill, :id)) %>

                      <div class="w-44 border p-2 m-2 bg-white">
                        <p class="h-16"><%= skill.name %></p>
                        <div class="flex justify-between items-center gap-x-2 p-2">
                          <.skill_evidence_link skill_panel={@skill_panel} skill={current_skill} skill_score={current_skill_score} query={@query} />
                          <.skill_reference_link :if={@me} skill_panel={@skill_panel} skill={current_skill} skill_score={current_skill_score} query={@query} />
                          <.skill_exam_link :if={@me} skill_panel={@skill_panel} skill={current_skill} skill_score={current_skill_score} query={@query} />
                        </div>

                        <div class="flex gap-2 p-2">
                          <label
                            id={"score-#{skill.id}-high"}
                            class="inline"
                            phx-click="update_score"
                            phx-value-class={@skill_class.class}
                            phx-value-score="high"
                            phx-value-score_id={current_skill_score.id}
                            phx-value-skill_id={skill.id}
                          >
                            <input
                              type="radio"
                              name={"score-#{skill.id}-high"}
                              checked={skill_score.score == :high}
                              class="hidden peer"
                            />
                            <span class={Map.get(score_mark_class(), "high")}></span>
                          </label>

                          <label
                            id={"score-#{skill.id}-middle"}
                            class="inline"
                            phx-click="update_score"
                            phx-value-class={@skill_class.class}
                            phx-value-score="middle"
                            phx-value-score_id={current_skill_score.id}
                            phx-value-skill_id={skill.id}
                          >
                            <input
                              type="radio"
                              name={"score-#{skill.id}-middle"}
                              checked={skill_score.score == :middle}
                              class="hidden peer"
                            />
                            <span class={Map.get(score_mark_class(), "middle")}></span>
                          </label>

                          <label
                            id={"score-#{skill.id}-low"}
                            class="inline"
                            phx-click="update_score"
                            phx-value-class={@skill_class.class}
                            phx-value-score="low"
                            phx-value-score_id={current_skill_score.id}
                            phx-value-skill_id={skill.id}
                          >
                            <input
                              type="radio"
                              name={"score-#{skill.id}-low"}
                              checked={skill_score.score == :low}
                              class="hidden peer"
                            />
                            <span class={Map.get(score_mark_class(), "low")}></span>
                          </label>
                        </div>
                      </div>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(skill_class: nil)
     |> clear_inner_flash()}
  end

  def update(assigns, socket) do
    {:ok, assign_assigns_with_current_if_updated(socket, assigns)}
  end

  defp assign_assigns_with_current_if_updated(socket, assigns) do
    prev_skill_class = socket.assigns.skill_class
    new_skill_class = assigns.skill_class

    if prev_skill_class == new_skill_class do
      socket
      |> assign(assigns)
    else
      socket
      |> assign(assigns)
      |> assign_current_skill_units()
      |> assign_current_skill_dict()
    end
  end

  defp assign_current_skill_units(socket) do
    skill_units =
      socket.assigns.skill_class
      |> Bright.Repo.preload(
        skill_units: [skill_categories: [skills: [:skill_reference, :skill_exam]]]
      )
      |> Map.get(:skill_units)

    skills =
      skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.flat_map(& &1.skills)

    socket
    |> assign(skill_units: skill_units)
    |> assign(current_skills: skills)
  end

  defp assign_current_skill_dict(socket) do
    current_skill_dict =
      socket.assigns.current_skills
      |> Map.new(&{&1.trace_id, &1})

    socket
    |> assign(current_skill_dict: current_skill_dict)
  end

  defp clear_inner_flash(socket) do
    assign(socket, :inner_flash, %{})
  end

  defp score_mark_class, do: @score_mark_class
end
