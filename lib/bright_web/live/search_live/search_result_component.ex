defmodule BrightWeb.SearchLive.SearchResultComponent do
  use BrightWeb, :live_component

  alias Bright.SkillScores

  import BrightWeb.TabComponents
  import BrightWeb.ChartComponents, only: [skill_gem: 1]
  import BrightWeb.SearchLive.ResultComponents

  import BrightWeb.SkillPanelLive.SkillPanelHelper,
    only: [assign_skill_score_dict: 1, assign_counter: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex">
      <div class="bg-white w-[450px]">
        <.tab
          id={"skill_search_result_tab_#{@index}"}
          tabs={@tabs}
          hidden_footer={true}
          selected_tab={@selected_tab}
          target={@myself}
        />

        <div class="relative">
          <p class="absolute left-0 ml-1 mt-1 top-0">
            クラス<%= Map.get(@selected_skill, :class, 1) %>
          </p>

          <div class="flex justify-between">
            <div class="mt-4 w-64">
                <.skill_gem
                  data={@skill_gem_data}
                  id={"skill-gem-#{@index}"}
                  labels={@skill_gem_labels}
                  size="sm"
                />
            </div>
            <.doughnut_area
              index={@index}
              counter={@counter}
              num_skills={@num_skills}
              skill_class_score={@skill_class_score}
            />
          </div>
        </div>
      </div>
      <div class="border-l border-brightGray-200 border-dashed w-[500px] ml-2 px-2">
        <div class="flex">
          <.job_area job={@user.user_job_profile} last_updated={@last_updated} />
          <.action_area skill_panel_id={@selected_tab} user={@user}/>
        </div>
        <div class="flex justify-between mt-8">
          <!--- β opacity-50 -> hover:opacity-50 に戻すこと --->
          <a
            class="bg-brightGray-900 border border-solid border-brightGray-300 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-56 opacity-50"
          >
          採用面談調整<br />βリリース（10月予定）から
          </a>
          <a class="bg-brightGray-900 border border-solid border-brightGray-300 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-56 opacity-50">
          人材チームに採用依頼 <br />βリリース（10月予定）から
          </a>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{skill_params: skills, user: user} = assigns, socket) do
    selected_skill = List.first(skills)

    socket
    |> assign(assigns)
    |> assign(:tabs, gen_tabs_tuple(skills))
    |> assign(:selected_tab, selected_skill.skill_panel)
    |> assign(:selected_skill, selected_skill)
    |> assign(:last_updated, SkillScores.get_latest_skill_score(user.id))
    |> assign_skills(selected_skill)
    |> then(&{:ok, &1})
  end

  def assign_skills(%{assigns: %{user: user}} = socket, selected_skill) do
    skill_class_score =
      Enum.find(user.skill_class_scores, fn score ->
        score.skill_class_id == selected_skill.skill_class_id
      end)

    skill_gem =
      SkillScores.get_skill_gem(
        user.id,
        selected_skill.skill_panel,
        Map.get(selected_skill, :class, 1)
      )

    socket
    |> assign(:skill_class_score, skill_class_score)
    |> assign(:skill_gem_data, get_skill_gem_data(skill_gem))
    |> assign(:skill_gem_labels, get_skill_gem_labels(skill_gem))
    |> assign_skill_score_dict()
    |> assign_counter()
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"tab_name" => tab_name},
        %{assigns: %{skill_params: skills}} = socket
      ) do
    selected_skill = Enum.find(skills, &(&1.skill_panel == tab_name))

    socket
    |> assign(:selected_tab, tab_name)
    |> assign(:selected_skill, selected_skill)
    |> assign_skills(selected_skill)
    |> then(&{:noreply, &1})
  end

  defp gen_tabs_tuple(skills) when length(skills) == 1,
    do: Enum.map(skills, &{&1.skill_panel, &1.skill_panel_name}) |> Enum.concat([{"", ""}])

  defp gen_tabs_tuple(skills) when length(skills) == 2,
    do: Enum.map(skills, &{&1.skill_panel, &1.skill_panel_name})

  defp gen_tabs_tuple(skills),
    do: Enum.map(skills, &{&1.skill_panel, String.slice(&1.skill_panel_name, 0..10)})

  defp get_skill_gem_data(skill_gem), do: [skill_gem |> Enum.map(fn x -> x.percentage end)]
  defp get_skill_gem_labels(skill_gem), do: skill_gem |> Enum.map(fn x -> x.name end)
end
