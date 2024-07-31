defmodule BrightWeb.OnboardingLive.WantsJobComponents do
  use BrightWeb, :live_component

  alias Bright.{Jobs, CareerFields}
  alias Bright.Jobs.Job

  @default_pos "engineer"
  @rank %{entry: "基礎", basic: "基本", advanced: "応用", expert: "高度"}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row">
      <div class="bg-white rounded w-full order-2 mt-4 lg:mt-0 lg:order-1">
        <div id="wants_job_panel" class="p-4">
          <%= for career_field <- @career_fields do %>
            <div id={career_field.name_en}>
              <h3 class={"border-l-4 px-2 border-#{career_field.name_en}-dark"}><%= career_field.name_ja %></h3>
              <%= for rank <- Ecto.Enum.values(Job, :rank) do %>
                <div class="my-8">
                  <p class="text-left text-[#777777] text-xl"><%= @rank[rank] %></p>
                  <hr class="h-[2px] bg-brightGray-50 mb-4" />
                  <div class="flex flex-wrap justify-center mt-2 lg:justify-start">
                    <% jobs = Map.get(@jobs, career_field.name_en, %{}) %>
                    <%= for job <- Map.get(jobs, rank, []) do %>
                      <%= if Enum.count(job.skill_panels) == 0 do %>
                        <div class="border-[3px] px-4 py-2 m-2 rounded w-[330px] h-40 flex flex-col bg-brightGray-50">
                          <div class="flex justify-between">
                            <p class="font-bold mb-2 w-44 truncate text-[#777777] opacity-85"><%= job.name %></p>
                            <button
                              class="rounded-lg border bg-white py-1 px-2 -mt-1 mb-2 text-xs"
                              phx-click="request"
                              phx-value-job={job.id}
                            >
                              リクエスト
                            </button>
                          </div>
                          <hr />
                          <p class="mt-2 text-[#777777] opacity-85 h-[40px] overflow-hidden">
                            <%= String.split(job.description, "。") |> List.first() %>
                          </p>
                        </div>
                      <% else %>
                        <% panel_id = List.first(job.skill_panels) |> Map.get(:id, nil) %>
                        <% score = Enum.find(@scores, & &1.id == panel_id) %>
                        <.link navigate={"#{@current_path}/jobs/#{job.id}"}>
                          <div class={"border-[3px] px-4 py-2 m-2 ounded w-[330px] h-40 flex flex-col #{if is_nil(score), do: "", else: "border-brightGreen-300"}"}>
                            <div class="flex justify-between mt-2">
                              <p class="font-bold mb-2 w-48 truncate"><%= job.name %></p>

                                <%= if is_nil(score) do %>
                                <p class="flex gap-x-2 h-8 mb-2 -mt-2">
                                  <img src={icon_path(:none)} width="20" height="23" />
                                  <img src={icon_path(:none)} width="20" height="23" />
                                  <img src={icon_path(:none)} width="20" height="23" />
                                  </p>
                                <% else %>
                                <p class="flex gap-x-2 h-8 mb-2">
                                    <%= for class <- score.skill_classes do %>
                                      <% class_score = List.first(class.skill_class_scores)%>
                                      <%= if is_nil(class_score) do %>
                                        <.link >
                                          <img src={icon_path(:none)} />
                                        </.link>
                                      <% else %>
                                        <.link navigate={~p"/panels/#{panel_id}?class=#{class.class}"} >
                                          <img src={icon_path(class_score.level)}  />
                                        </.link>
                                      <% end %>
                                    <% end %>
                                  </p>
                                <% end %>
                            </div>
                            <hr />
                            <p class="mt-2 text-[#777777] text-sm opacity-85 h-[60px] overflow-scroll">
                              <%= String.split(job.description, "。") |> List.first() %>
                            </p>
                            <div class="flex gap-x-2 mt-2">
                              <%= for tag <-  job.career_fields do %>
                                <p class={"border rounded-full p-1 text-xs text-#{tag.name_en}-dark bg-#{tag.name_en}-light"}>
                                  <%= tag.name_ja %>
                                </p>
                              <% end %>
                            </div>
                          </div>
                        </.link>
                      <% end %>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
      <div class="w-full lg:w-60 lg:ml-12 bg-white h-full p-2 sticky top-16 lg:top-2 order-1 lg:order-2 flex flex-row lg:flex-col">
        <%= for career_field <- @career_fields do %>
          <p
            class={"cursor-default px-4 py-2 lg:mb-2 text-xs lg:text-lg text-[#004D36] #{if @pos == career_field.name_en, do: "border-l-4 border-#{career_field.name_en}-dark bg-#{career_field.name_en}-light", else: "ml-1"}"}
            phx-click="scroll_to"
            phx-value-pos={career_field.name_en}
            phx-target={@myself}
          >
            <%= career_field.name_ja %>
          </p>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    jobs = Jobs.list_jobs_group_by_career_field_and_rank()

    socket
    |> assign(:rank, @rank)
    |> assign(:jobs, jobs)
    |> assign(:pos, @default_pos)
    |> then(&{:ok, &1})
  end

  @impl true
  def update(assigns, socket) do
    career_fields = CareerFields.list_career_fields()

    socket
    |> assign(assigns)
    |> assign(:career_fields, career_fields)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("scroll_to", %{"pos" => pos}, socket) do
    socket
    |> assign(:pos, pos)
    |> push_event("scroll-to", %{"id" => pos})
    |> then(&{:noreply, &1})
  end

  defp icon_base_path(file), do: "/images/common/icons/#{file}"
  defp icon_path(:none), do: icon_base_path("gemGray.svg")
  defp icon_path(:beginner), do: icon_base_path("jemLow.svg")
  defp icon_path(:normal), do: icon_base_path("jemMiddle.svg")
  defp icon_path(:skilled), do: icon_base_path("jemHigh.svg")
end
