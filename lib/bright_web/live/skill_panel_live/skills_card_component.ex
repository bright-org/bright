defmodule BrightWeb.SkillPanelLive.SkillsCardComponent do
  # スキルパネル画面 スキル一覧をカード形式で表示するコンポーネント
  # （スキルスコア入力に関しては、LiveViewで行いこちらでは制御しない）

  use BrightWeb, :live_component

  import BrightWeb.SkillPanelLive.SkillsComponents

  alias BrightWeb.BrightCoreComponents

  # スコアと対応するHTML class属性
  @score_mark_class %{
    "high" =>
      "score-mark-high bg-white border border-brightGray-300 flex cursor-pointer h-6 items-center justify-center rounded w-6 before:content-[''] before:h-3 before:w-3 before:rounded-full before:bg-brightGray-300 before:block peer-checked:bg-brightGreen-300 peer-checked:border-brightGreen-300 peer-checked:before:bg-white hover:filter hover:brightness-[80%]",
    "middle" =>
      "score-mark-middle bg-white border border-brightGray-300 flex cursor-pointer h-6 items-center justify-center rounded w-6 before:content-[''] before:h-0 before:w-0 before:border-solid before:border-t-0 before:border-r-8 before:border-l-8 before:border-transparent before:border-b-[14px] before:border-b-brightGray-300 peer-checked:bg-brightGreen-300 peer-checked:border-brightGreen-300 peer-checked:before:border-b-white hover:filter hover:brightness-[80%]",
    "low" =>
      "score-mark-low bg-white border border-brightGray-300 flex cursor-pointer h-6 items-center justify-center rounded w-6 before:content-[''] before:block before:w-3 before:h-1 before:bg-brightGray-300 peer-checked:bg-brightGreen-300 peer-checked:border-brightGreen-300 peer-checked:before:bg-white hover:filter hover:brightness-[80%]"
  }

  def render(assigns) do
    ~H"""
    <div id={@id} class="bg-brightGray-50">
      <BrightCoreComponents.flash_group flash={@inner_flash} />
      <div class="flex flex-col gap-2">
        <%= for {skill_unit, index} <- Enum.with_index(@skill_units) do %>
          <div id={"unit-#{index + 1}"} class="px-8 py-2">

            <div id={"unit-#{index + 1}-sp"} class="flex gap-x-4">
              <span class="text-lg font-bold"><%= skill_unit.name %></span>
            </div>

            <div class="flex flex-wrap gap-2">
              <%= for skill_category <- skill_unit.skill_categories do %>
                <div class="bg-white rounded-lg px-4 pt-4 pb-2">
                    <%= skill_category.name %>
                  <div class="flex flex-wrap mt-2">
                    <%= for skill <- skill_category.skills do %>

                      <% skill_score = @current_skill_score_dict[skill.id] %>
                      <% current_skill = Map.get(@current_skill_dict, skill.trace_id, %{}) %>
                      <% current_skill_score = Map.get(@current_skill_score_dict, Map.get(current_skill, :id)) %>

                      <div class="w-40 border mb-2 mr-2 bg-white">
                        <p class="h-12 text-xs p-2"><%= skill.name %></p>
                        <div class="flex justify-between items-center gap-x-2 p-2">
                          <.skill_evidence_link skill_panel={@skill_panel} skill={current_skill} skill_score={current_skill_score} query={@query} />
                          <.skill_reference_link :if={@me} skill_panel={@skill_panel} skill={current_skill} skill_score={current_skill_score} query={@query} />
                          <.skill_exam_link :if={@me} skill_panel={@skill_panel} skill={current_skill} skill_score={current_skill_score} query={@query} />
                        </div>

                        <div class="flex justify-end gap-2 p-2 bg-[#F5FBFB]">
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
