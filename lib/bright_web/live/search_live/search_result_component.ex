defmodule BrightWeb.SearchLive.SearchResultComponent do
  use BrightWeb, :live_component

  alias Bright.SkillScores
  alias Bright.UserProfiles

  import BrightWeb.TabComponents
  import BrightWeb.ChartComponents, only: [skill_gem: 1]
  import BrightWeb.DisplayUserHelper, only: [encrypt_user_name: 1]
  import BrightWeb.SearchLive.ResultComponents
  import BrightWeb.PathHelper
  import BrightWeb.ProfileComponents, only: [profile_small_inline: 1]

  import BrightWeb.SkillPanelLive.SkillPanelHelper,
    only: [assign_skill_score_dict: 1, assign_counter: 1]

  @impl true
  def render(assigns) do
    if is_nil(assigns.skill_class_score),
      do: Sentry.capture_message("BrightWeb.SearchLive.SearchResultComponent: データが表示できません")

    ~H"""
    <div class="flex flex-col">
      <%= if !@anon do %>
      <.profile_small_inline
          user_name={@user.name}
          title={@user.user_profile.title}
          icon_file_path={UserProfiles.icon_url(@user.user_profile.icon_file_path)}
          detail={@user.user_profile.detail}
      />
      <% else %>
      <.profile_small_inline
          user_name={"非公開"}
          icon_file_path={"/images/avatar.png"}
      />
      <% end %>
      <div class="flex border border-brightGray-200 min-h-64 max-h-76 mb-2 overflow-hidden p-2 rounded">
        <%= if is_nil(@skill_class_score) do %>
        <div class="bg-white w-[450px] flex items-center justify-center">
          <p class="text-start">データが表示できません</p>
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
              anon={@anon}
              skill_panel={@selected_skill_panel}
              stock_user_ids={@stock_user_ids}
            />
            </div>
          </div>
          <div :if={@search} class="flex justify-end mt-8">
            <!--- β opacity-50 -> hover:opacity-50 に戻すこと --->
            <a
              phx-click={
                if @hr_enabled,
                do: JS.show(to: "#create_interview_modal") |> JS.push("open", value: %{user: @user.id, skill_params: @skill_params}, target: "#create_interview_modal"),
                else: JS.push("open_free_trial",target: @myself)
              }
              class="self-center bg-base border border-solid border-brightGray-300 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-56 hover:opacity-50"
            >
            面談の打診
            </a>
            <a :if={false} class="bg-brightGray-900 border border-solid border-brightGray-300 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-56 opacity-50">
            採用・育成チームに採用依頼 <br />βリリース（11月予定）から
            </a>
          </div>
          <div :if={!@search} class="flex justify-start mt-8">
            <.link
              class="bg-white text-sm block border border-solid border-brightGreen-300 cursor-pointer font-bold lg:mx-2 my-1 py-1 rounded text-center select-none text-brightGreen-300 w-28 hover:opacity-50"
              target="_blank"
              rel="noopener noreferrer"
              href={
                skill_panel_path("graphs",%{id: @selected_skill_panel.skill_panel}, %{name_encrypted: encrypt_user_name(@user), name: @user.name},false,@anon)
                <> "?class=#{@selected_skill_panel.class}"
              }
            >
              成長パネル
            </.link>
            <.link
              class="bg-white text-sm block border border-solid border-brightGreen-300 cursor-pointer font-bold lg:mx-2 my-1 py-1 rounded text-center select-none text-brightGreen-300 w-28 hover:opacity-50"
              target="_blank"
              rel="noopener noreferrer"
              href={if @anon, do: "/mypage/anon/#{encrypt_user_name(@user)}", else: "/mypage/#{@user.name}"}
            >
              保有スキル
            </.link>
          </div>
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
      case skill_class_score do
        nil ->
          []

        _ ->
          SkillScores.get_skill_gem(
            user.id,
            selected_skill_panel.skill_panel,
            selected_skill_panel.class
          )
      end

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

    send_update(BrightWeb.SubscriptionLive.FreeTrialRecommendationComponent,
      id: "free_trial_recommendation_modal",
      open: true,
      service_code: "hr_basic",
      on_submit: fn _ ->
        send_update(BrightWeb.SearchLive.SearchResultsComponent,
          id: "user_search_result",
          hr_enabled: true
        )

        send_update(BrightWeb.SearchLive.SkillSearchComponent,
          id: "skill_search_modal",
          click_away_disable: false
        )
      end,
      on_close: fn ->
        send_update(BrightWeb.SearchLive.SkillSearchComponent,
          id: "skill_search_modal",
          click_away_disable: false
        )
      end
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
