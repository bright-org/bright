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
            クラス<%= @selected_skill_panel.class %>
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
      <div class="border-l border-brightGray-200 border-dashed w-[512px] ml-2 px-2">
        <div class="flex">
          <.job_area job={@user.user_job_profile} last_updated={@last_updated} />
          <.action_area
            user={@user}
            skill_panel={@selected_skill_panel}
            stock_user_ids={@stock_user_ids}
          />
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
  def update(%{skill_params: skill_params, user: user} = assigns, socket) do
    selected_skill_panel = List.first(skill_params)

    socket
    |> assign(assigns)
    |> assign(:tabs, gen_tabs_tuple(skill_params))
    |> assign(:selected_tab, selected_skill_panel.skill_panel)
    |> assign(:selected_skill_panel, selected_skill_panel)
    |> assign(:last_updated, SkillScores.get_latest_skill_score(user.id))
    |> assign_skill_panels(selected_skill_panel)
    |> then(&{:ok, &1})
  end

  def assign_skill_panels(%{assigns: %{user: user}} = socket, selected_skill_panel) do
    skill_class_score =
      Enum.find(user.skill_class_scores, fn score ->
        score.skill_class_id == selected_skill_panel.skill_class_id
      end)

    skill_gem =
      SkillScores.get_skill_gem(
        user.id,
        selected_skill_panel.skill_panel,
        selected_skill_panel.class
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
        %{assigns: %{skill_params: skill_params}} = socket
      ) do
    selected_skill_panel = Enum.find(skill_params, &(&1.skill_panel == tab_name))

    socket
    |> assign(:selected_tab, tab_name)
    |> assign(:selected_skill_panel, selected_skill_panel)
    |> assign_skill_panels(selected_skill_panel)
    |> then(&{:noreply, &1})
  end

  defp gen_tabs_tuple(skill_params) when length(skill_params) == 1,
    do: Enum.map(skill_params, &{&1.skill_panel, &1.skill_panel_name}) |> Enum.concat([{"", ""}])

  defp gen_tabs_tuple(skill_params),
    do: Enum.map(skill_params, &{&1.skill_panel, &1.skill_panel_name})

  defp get_skill_gem_data(skill_gem), do: [skill_gem |> Enum.map(fn x -> x.percentage end)]
  defp get_skill_gem_labels(skill_gem), do: skill_gem |> Enum.map(fn x -> x.name end)
end
