defmodule BrightWeb.OnboardingLive.SkillPanels do
  alias Bright.SkillScores
  use BrightWeb, :live_view

  alias Bright.Jobs
  alias Bright.SkillPanels
  alias Bright.UserSkillPanels
  alias Bright.Onboardings
  alias Bright.Onboardings.UserOnboarding

  import BrightWeb.OnboardingLive.Index, only: [hidden_more_skills: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <section class="bg-brightGray-50">
      <h1 class={["font-bold text-3xl",hidden_more_skills(@current_path)]}>
        <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
          スキルを選ぶ
        </span>
      </h1>

      <div class="p-4 lg:p-8">
        <ol class="mt-4 lg:mt-0 mb-1 flex items-center whitespace-nowrap">
          <li class="inline-flex items-center">
            <.link navigate={@return_to} class="flex items-center text-sm text-engineer-dark">
              ジョブパネルを選ぶ
            </.link>
            <p class="shrink-0 size-5 text-engineer-dark dark:text-neutral-600 ml-4">/</p>
          </li>
          <li class="inline-flex items-center">
            <p class="flex items-center text-sm text-engineer-dark">
              <%= @job.name %>
            </p>
            <p class="shrink-0 size-5 text-engineer-dark dark:text-neutral-600 ml-4">/</p>
          </li>
        </ol>

        <div class="bg-white p-2 lg:p-4 rounded">
          <div class="flex flex-col lg:flex-row justify-between">
            <div class="flex flex-col lg:flex-row flex-start mb-4">
              <p class="text-xl py-2 pr-4"><%= @job.name %></p>
              <p class="pl-4 border-l-4 border-[#555555] inline-flex items-center">MAX : <%= @class.name %></p>
            </div>
            <span class={"px-2 lg:px-4 py-2 mb-4 w-24 rounded-full text-xs h-8 text-center bg-#{@career_field.name_en}-light text-#{@career_field.name_en}-dark"}>
              <%= @career_field.name_ja %>
            </span>
          </div>

          <button
            class="rounded-md px-4 py-2 mb-8 bg-brightGreen-300 text-white flex text-lg"
            phx-click={JS.push("select_skill_panel", value: %{id: @skill_panel.id, name: @skill_panel.name, type: "input"})}
          >
            <span class="material-icons-outlined mt-[3px] mr-1 text-white text-md">edit</span>
            スキルを入力
          </button>
          <div class="flex flex-col lg:flex-row w-full">
            <div class="lg:w-1/2">
              <% # descriptionの準備が整うまで非表示 %>
              <div :if={false} class="mb-8">
                <p class="text-lg text-brightGray-400"><%= @job.name %>とは？</p>
                <hr class="h-[2px] bg-brightGray-50 my-2" />
                <p class="pl-4 words-break"><%= @job.description %></p>
                <p :if={false} class="text-end">具体例を知りたい</p>
              </div>

              <div >
                <% filter = String.split(@job.name) |> List.last() %>
                <p class="text-base lg:text-lg text-brightGray-400"><%= filter %>のジョブルート</p>
                <hr class="h-[2px] bg-brightGray-50 my-2" />
                <.live_component
                  id="job_route"
                  job={@job}
                  current_path={@current_path}
                  career_field={@career_field}
                  skill_panel={@skill_panel}
                  scores={@scores}
                  filter={filter}
                  module={BrightWeb.OnboardingLive.JobRouteComponents}
                />

              </div>
            </div>
            <div class="lg:w-1/2 lg:ml-8">
              <p class="text-base lg:text-lg text-brightGray-400"><%= "#{@job.name} に含まれる知識エリア／習得率" %></p>
              <hr class="h-[2px] bg-brightGray-50 my-2" />
              <ul class="mt-4 px-4">
                  <%= for skill_unit <- @skill_units do %>
                    <% score = Enum.find(@skill_score, & &1.skill_unit_id == skill_unit.id) || %{percentage: 0}%>
                    <li class="rounderd border-2 px-4 py-2 mb-3 flex flex-col">
                      <div class="flex flex-col lg:flex-row justify-between overflow-x-hidden">
                        <span class="mr-4 text-lg text-brightGray-400"><%= skill_unit.name %></span>
                        <div class="flex flex-wrap">
                          <%= for {category, index} <- Enum.with_index(skill_unit.skill_categories) do %>
                            <span :if={index < 5} class="rounded-full bg-brightGray-50 mt-2 mr-2 p-1 px-2 text-xs">
                              <%= category.name %>
                            </span>
                          <% end %>
                        <span :if={length(skill_unit.skill_categories) > 5} class="rounded-full bg-brightGray-50 mr-2 mt-2 px-2 py-1 text-xs">
                          <%= "+#{length(skill_unit.skill_categories) - 5}"%>
                        </span>
                        </div>
                      </div>
                      <div class="flex mt-4">
                        <div class="flex w-full h-2 mr-1 bg-gray-200 rounded-full overflow-hidden " role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">
                          <div
                            class="flex flex-col justify-center rounded-full overflow-hidden bg-brightGreen-300 whitespace-nowrap transition duration-500 "
                            style={"width: #{score.percentage}%"}
                          />
                        </div>
                        <span class="-mt-[8px] lg:-mt-[2px]"><%= round(score.percentage) %>%</span>
                      </div>
                  </li>
                  <% end %>
              </ul>
            </div>
          </div>
        </div>
      </div>

    </section>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "ジョブパネル")}
  end

  @impl true
  def handle_params(%{"job_id" => id, "career_field" => career_field}, uri, socket) do
    job = Jobs.get_job!(id)
    current_path = URI.parse(uri).path |> Path.split() |> Enum.at(1) |> String.replace("/", "")
    career_fields = Jobs.list_skill_panels_group_by_career_field(id)
    [skill_panel | _] = Map.values(career_fields) |> List.flatten() |> Enum.uniq()
    skill_class = SkillPanels.get_skill_class_by_skill_panel_id(skill_panel.id)

    skill_score =
      SkillScores.list_skill_unit_scores_by_user_skill_class(
        socket.assigns.current_user,
        skill_class
      )

    job_with_scores =
      SkillPanels.list_skill_panels_with_score(
        socket.assigns.current_user.id,
        career_field
      )

    class3 =
      skill_panel
      |> Bright.Repo.preload(:skill_classes)
      |> Map.get(:skill_classes, [])
      |> Enum.max_by(& &1.class)

    socket
    |> assign(:job, job)
    |> assign(:scores, job_with_scores)
    |> assign(:current_path, current_path)
    |> assign(:return_to, "/#{current_path}?career_field=#{career_field}&job=#{id}")
    |> assign(:class, class3)
    |> assign(:skill_panel, skill_panel)
    |> assign(:skill_units, skill_class.skill_units)
    |> assign(:skill_score, skill_score)
    |> assign(:career_field, Map.keys(career_fields) |> Enum.find(&(&1.name_en == career_field)))
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("request", _params, socket) do
    {:noreply, put_flash(socket, :info, "ジョブパネルのリクエストを受け付けました")}
  end

  def handle_event(
        "select_skill_panel",
        %{"id" => skill_panel_id, "name" => name},
        %{assigns: %{current_user: user}} = socket
      ) do
    finish_onboarding(user.user_onboardings, user.id, skill_panel_id)

    socket
    |> select_skill_panel(user.id, skill_panel_id, name)
    |> redirect(to: "/panels/#{skill_panel_id}")
    |> then(&{:noreply, &1})
  end

  defp select_skill_panel(socket, user_id, skill_panel_id, name) do
    case UserSkillPanels.user_skill_panel_exists?(user_id, skill_panel_id) do
      true -> socket
      false -> put_flash(socket, :info, "スキルパネル:#{name}を取得しました")
    end
  end

  defp finish_onboarding(nil, user_id, skill_panel_id) do
    {:ok, _onboarding} =
      Onboardings.create_user_onboarding(%{
        completed_at: NaiveDateTime.utc_now(),
        user_id: user_id,
        skill_panel_id: skill_panel_id
      })
  end

  defp finish_onboarding(%UserOnboarding{}, _, _), do: false
end
