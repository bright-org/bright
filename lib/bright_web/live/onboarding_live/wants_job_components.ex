defmodule BrightWeb.OnboardingLive.WantsJobComponents do
  use BrightWeb, :live_component

  alias Bright.{Jobs, CareerFields}
  alias Bright.Jobs.Job

  @rank %{entry: "基礎", basic: "基本", advanced: "応用", expert: "高度"}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row">
      <div class="bg-white rounded w-full order-2 mt-4 lg:mt-0 lg:order-1">
        <div id="wants_job_panel" class="p-4" phx-hook="ScrollPos">
          <%= for career_field <- @career_fields do %>
            <div id={career_field.name_en}>
              <h3 class={"border-l-4 px-2 border-#{career_field.name_en}-dark"}><%= career_field.name_ja %></h3>
              <%= for rank <- Ecto.Enum.values(Job, :rank) do %>
                <div class="my-8">
                  <p class="text-left text-brightGray-400 text-xl"><%= @rank[rank] %></p>
                  <hr class="h-[2px] bg-brightGray-50 mb-4" />
                  <div class="flex flex-wrap justify-center mt-2 lg:justify-start">
                    <% jobs = Map.get(@jobs, career_field.name_en, %{}) %>
                    <%= for job <- Map.get(jobs, rank, []) do %>
                      <%= if Enum.count(job.skill_panels) == 0 do %>
                        <.locked_job job={job} />
                      <% else %>
                        <% panel_id = List.first(job.skill_panels) |> Map.get(:id, nil) %>
                        <.unlocked_job
                          panel_id={panel_id}
                          score={Enum.find(@scores, & &1.id == panel_id)}
                          current_path={@current_path}
                          job={job}
                          career_field={career_field}
                        />
                      <% end %>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
      <div class="lg:ml-12 bg-white h-full p-2 sticky top-16 lg:top-2 order-1 lg:order-2">
        <div class="flex flex-row lg:flex-col w-full lg:w-[240px] ">
        <%= for career_field <- @career_fields do %>
          <p
            class={"cursor-pointer px-1 lg:px-4 py-2 lg:mb-2 text-xs lg:text-lg text-[#004D36] #{if @pos == career_field.name_en, do: "border-l-4 border-#{career_field.name_en}-dark bg-#{career_field.name_en}-light", else: "ml-1"}"}
            phx-click="scroll_to"
            phx-value-pos={career_field.name_en}
          >
            <%= career_field.name_ja %>
          </p>
        <% end %>
        </div>
      </div>
    </div>
    """
  end

  def locked_job(assigns) do
    ~H"""
    <div class="border-[3px] px-2 lg:px-4 m-2 rounded w-[150px] lg:w-[340px] h-[100px] lg:h-[74px] flex flex-col bg-brightGray-50">
      <div class="flex flex-col lg:flex-row justify-between">
        <p class="flex my-2 lg:w-44 truncate text-xs text-brightGray-400 opacity-85">
          <img  class="w-[22px] h-[22px] -mt-[2px] mr-[2px]" src="/images/common/icons/biLock.svg" />
          <%= String.replace(@job.name, "🔐", "") %>
        </p>
        <button
          class="rounded border bg-white h-[28px] mt-1 px-2 text-xs hover:filter hover:brightness-[80%]"
          phx-click="request"
          phx-value-job={@job.id}
        >
          リクエストを送る
        </button>
      </div>
    </div>
    """
  end

  def unlocked_job(assigns) do
    ~H"""
    <div phx-click={JS.navigate("/#{@current_path}/jobs/#{@job.id}?career_field=#{@career_field.name_en}")} class="cursor-pointer">
      <div
        id={"#{@career_field.name_en}-#{@job.id}"}
        class={"px-2 lg:px-4 m-2 rounded w-[150px] lg:w-[340px] h-[100px] lg:h-[74px] flex flex-col hover:bg-[#F5FBFB] #{if is_nil(@score), do: "border-[2px]", else: "border border-brightGreen-300"}"}
      >
        <div class="flex flex-col lg:flex-row justify-between mt-2 mb-[4px]">
          <p class="text-xs lg:w-44 lg:font-bold lg:mt-1 mb-1 lg:mb-0"><%= @job.name %></p>
          <%= if is_nil(@score) do %>
            <p class="flex mb-[4px] ">
              <img src={icon_path(:none)} width="20" height="23" class="mr-2" />
              <img src={icon_path(:none)} width="20" height="23" class="mr-2" />
              <img src={icon_path(:none)} width="20" height="23" class="mr-2" />
            </p>
          <% else %>
            <p class="flex mb-[4px]">
              <%= for class <- @score.skill_classes do %>
                <% class_score = List.first(class.skill_class_scores)%>
                <%= if is_nil(class_score) do %>
                  <.link>
                    <img src={icon_path(:none)} class="mr-2" />
                  </.link>
                <% else %>
                  <.link navigate={~p"/panels/#{@panel_id}?class=#{class.class}"} >
                    <img src={icon_path(class_score.level)}  class="hover:filter hover:brightness-[80%] mr-2" />
                  </.link>
                <% end %>
              <% end %>
            </p>
          <% end %>
        </div>
        <hr />
        <div class="flex gap-x-1 lg:gap-x-2 mt-2 lg:mt-1 mb-[4px]" >
          <%= for tag <- @job.career_fields do %>
            <p class={"border rounded-full px-[1px] lg:px-1 h-[20px] text-xs text-#{tag.name_en}-dark bg-#{tag.name_en}-light"}><%= tag.name_ja %></p>
          <% end %>
        </div>
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

  defp icon_base_path(file), do: "/images/common/icons/#{file}"
  defp icon_path(:none), do: icon_base_path("gemGray.svg")
  defp icon_path(:beginner), do: icon_base_path("jemLow.svg")
  defp icon_path(:normal), do: icon_base_path("jemMiddle.svg")
  defp icon_path(:skilled), do: icon_base_path("jemHigh.svg")
end
