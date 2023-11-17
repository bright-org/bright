defmodule BrightWeb.SearchLive.SearchResultComponent do
  use BrightWeb, :live_component

  alias Bright.SkillScores

  import BrightWeb.TabComponents
  import BrightWeb.ChartComponents, only: [skill_gem: 1]
  import BrightWeb.DisplayUserHelper, only: [encrypt_user_name: 1]
  import BrightWeb.SearchLive.ResultComponents
  import BrightWeb.PathHelper

  import BrightWeb.SkillPanelLive.SkillPanelHelper,
    only: [assign_skill_score_dict: 1, assign_counter: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex">
      <%= if is_nil(@skill_class_score) do %>
      <div class="bg-white w-[450px] flex items-center justify-center">
        <p class="text-start">データが破損しています</p>
      </div>
      <% else %>
      <div class="bg-white w-[450px]">
        <.tab
          id={"#{@prefix}_skill_search_result_tab_#{@index}"}
          tabs={@tabs}
          hidden_footer={true}
          selected_tab={@selected_tab}
          target={@myself}
        />

        <div class="relative">
          <p class="absolute left-0 ml-1 mt-1 top-0">
            クラス<%= @selected_skill_panel.class %>
          </p>

          <div class="flex">
            <div class="mt-4 w-64">
                <.skill_gem
                  data={@skill_gem_data}
                  id={"#{@prefix}-skill-gem-#{@index}"}
                  labels={@skill_gem_labels}
                  size="sm"
                />
            </div>
            <.doughnut_area
              index={"#{@prefix}_#{@index}"}
              counter={@counter}
              num_skills={@num_skills}
              skill_class_score={@skill_class_score}
            />
          </div>
        </div>
      </div>
      <% end %>
      <div class="border-l border-brightGray-200 border-dashed w-[512px] ml-2 px-2">
        <div class="flex">
          <.job_area job={@user.user_job_profile} last_updated={@user.last_updated} />
          <div :if={@search}>
          <.action_area
            user={@user}
            skill_panel={@selected_skill_panel}
            stock_user_ids={@stock_user_ids}
          />
          </div>
        </div>
        <div :if={@search} class="flex justify-between mt-8">
          <!--- β opacity-50 -> hover:opacity-50 に戻すこと --->
          <a
            phx-click={
              if @hr_enabled,
              do: JS.show(to: "#create_interview_modal") |> JS.push("open", value: %{user: @user.id, skill_params: @skill_params}, target: "#create_interview_modal"),
              else: JS.push("open_free_trial",target: @myself)
            }
            class="self-center bg-base border border-solid border-brightGray-300 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-56 hover:opacity-50"
          >
          面談調整
          </a>
          <a class="bg-brightGray-900 border border-solid border-brightGray-300 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-56 opacity-50">
          採用・育成チームに採用依頼 <br />βリリース（11月予定）から
          </a>
        </div>
        <div :if={!@search} class="flex justify-between mt-8">
          <.link
            class="bg-white block border border-solid border-brightGreen-300 cursor-pointer font-bold mb-2 px-4 py-1 rounded select-none text-center text-brightGreen-300 w-40 hover:opacity-50"
            target="_blank"
            rel="noopener noreferrer"
            href={
              skill_panel_path("graphs",%{id: @selected_skill_panel.skill_panel}, %{name_encrypted: encrypt_user_name(@user)},false,true)
              <> "?class=#{@selected_skill_panel.class}"
            }
          >
            成長グラフの確認
          </.link>
          <.link
            class="bg-white block border border-solid border-brightGreen-300 cursor-pointer font-bold mb-2 px-4 py-1 rounded select-none text-center text-brightGreen-300 w-40 hover:opacity-50"
            target="_blank"
            rel="noopener noreferrer"
            href={"/mypage/anon/#{encrypt_user_name(@user)}"}
          >
          保有スキルの確認
          </.link>

        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{skill_params: skill_params} = assigns, socket) do
    selected_skill_panel = List.first(skill_params)

    socket
    |> assign(assigns)
    |> assign(:tabs, gen_tabs_tuple(skill_params))
    |> assign(:selected_tab, "#{selected_skill_panel.skill_panel}_#{selected_skill_panel.class}")
    |> assign(:selected_skill_panel, selected_skill_panel)
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

    case length(skill_gem) > 2 do
      true ->
        socket
        |> assign(:skill_class_score, skill_class_score)
        |> assign(:skill_gem_data, get_skill_gem_data(skill_gem))
        |> assign(:skill_gem_labels, get_skill_gem_labels(skill_gem))
        |> assign_skill_score_dict()
        |> assign_counter()

      false ->
        assign(socket, :skill_class_score, nil)
    end
  end

  @impl true
  def handle_event("open_free_trial", _params, socket) do
    send_update(BrightWeb.SearchLive.SkillSearchComponent,
      id: "skill_search_modal",
      click_away_disable: true
    )

    send_update(BrightWeb.SubscriptionLive.CreateFreeTrialComponent,
      id: "free_trial_modal",
      open: true
    )

    {:noreply, socket}
  end

  def handle_event(
        "tab_click",
        %{"tab_name" => tab_name},
        %{assigns: %{skill_params: skill_params}} = socket
      ) do
    selected_skill_panel = Enum.find(skill_params, &("#{&1.skill_panel}_#{&1.class}" == tab_name))

    socket
    |> assign(:selected_tab, tab_name)
    |> assign(:selected_skill_panel, selected_skill_panel)
    |> assign_skill_panels(selected_skill_panel)
    |> then(&{:noreply, &1})
  end

  defp gen_tabs_tuple(skill_params) when length(skill_params) == 1,
    do:
      Enum.map(skill_params, &{"#{&1.skill_panel}_#{&1.class}", &1.skill_panel_name})
      |> Enum.concat([{"", ""}])

  defp gen_tabs_tuple(skill_params),
    do: Enum.map(skill_params, &{"#{&1.skill_panel}_#{&1.class}", &1.skill_panel_name})

  defp get_skill_gem_data(skill_gem), do: [skill_gem |> Enum.map(fn x -> x.percentage end)]
  defp get_skill_gem_labels(skill_gem), do: skill_gem |> Enum.map(fn x -> x.name end)
end
