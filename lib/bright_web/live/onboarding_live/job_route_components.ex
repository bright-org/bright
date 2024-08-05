defmodule BrightWeb.OnboardingLive.JobRouteComponents do
  use BrightWeb, :live_component

  alias Bright.Jobs
  alias Bright.Jobs.Job

  @rank Ecto.Enum.values(Job, :rank)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row bg-white rounded w-full h-[420px] lg:h-full overflow-scroll order-2 lg:p-4 lg:mt-0 lg:order-1">
      <%= for career_field <- @career_fields do %>
        <div id={career_field.name_en} class="flex">
          <%= for rank <- @ranks do %>
            <% jobs = filter_job(@jobs, career_field, rank, @filter) %>
            <div class="mr-4 flex flex-col w-1/2 lg:w-full">
              <div class="flex h-8">
                <%= if rank == @job.rank do  %>
                  <p class="flex-none text-left px-2 h-[20px] lg:h-[24px] rounded-full bg-brightGreen-300  text-xs lg:text-sm text-white mr-2">
                    <%= Enum.find_index(@rank,& &1 == rank) + 1 %>
                  </p>
                  <p class="text-xs lg:text-sm"><%= @job.name %></p>
                  <p :if={Enum.find_index(@rank,& &1 == rank) != 3}class="grow border-t-[4px] mt-[10px] ml-2 border-brightGreen-300 opacity-50" />
                <% else %>
                  <p :if={!is_nil(rank)} class="flex-none text-left px-2 h-[20px] lg:h-[24px] rounded-full border border-brightGray-200 text-brightGray-200 text-xs lg:text-sm mr-2">
                    <%= Enum.find_index(@rank, & &1 == rank) + 1 %>
                    <p class="text-xs lg:text-sm">Next</p>
                  </p>
                <% end %>
              </div>
              <div class="flex flex-col justify-center mt-2 lg:justify-start">
                <%= for job <- jobs do %>
                  <%= if Enum.count(job.skill_panels) == 0 do %>
                    <.locked_job job={job} />
                  <% else %>
                    <% panel_id = List.first(job.skill_panels) |> Map.get(:id, nil) %>
                    <.unlocked_job
                      current_path={@current_path}
                      panel_id={panel_id}
                      score={Enum.find(@scores, & &1.id == panel_id)}
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
    """
  end

  def locked_job(assigns) do
    ~H"""
    <div class="border-[3px] px-2 lg:px-4 lg:pt-2 pb-[34px] lg:pb-[40px] my-2 rounded w-[150px] lg:w-[330px] h-30 flex flex-col bg-brightGray-50">
      <div class="flex flex-col lg:flex-row justify-between mt-2">
        <p class="font-bold my-2 lg:w-44 truncate text-xs lg:text-base text-brightGray-400 opacity-85 h-[28px]"><%= @job.name %></p>
        <button
          class="rounded-lg border bg-white py-1 px-2 mb-2 text-xs hover:filter hover:brightness-[80%]"
          phx-click="request"
          phx-value-job={@job.id}
        >
          リクエスト
        </button>
      </div>
      <hr />
    </div>
    """
  end

  def unlocked_job(assigns) do
    ~H"""
    <.link navigate={"/#{@current_path}/jobs/#{@job.id}?career_field=#{@career_field.name_en}"}>
      <div
        id={"#{@career_field.name_en}-#{@job.id}"}
        class={"border-[3px] px-2 lg:px-4 py-2 my-2 rounded w-[150px] lg:w-[330px] h-30 flex flex-col  hover:bg-[#F5FBFB] #{if is_nil(@score), do: "", else: "border-brightGreen-300"}"}
      >
        <div class="flex flex-col lg:flex-row justify-between mt-2">
          <p class="font-bold text-xs lg:text-base mb-2 lg:w-48 truncate h-[28px]"><%= @job.name %></p>
          <%= if is_nil(@score) do %>
            <p class="flex gap-x-2 h-8 mb-4 -mt-2">
              <img src={icon_path(:none)} width="20" height="23" />
              <img src={icon_path(:none)} width="20" height="23" />
              <img src={icon_path(:none)} width="20" height="23" />
            </p>
          <% else %>
            <p class="flex gap-x-2 h-8 mb-2">
              <%= for class <- @score.skill_classes do %>
                <% class_score = List.first(class.skill_class_scores)%>
                <%= if is_nil(class_score) do %>
                  <.link >
                    <img src={icon_path(:none)} />
                  </.link>
                <% else %>
                  <.link navigate={~p"/panels/#{@panel_id}?class=#{class.class}"} >
                    <img src={icon_path(class_score.level)}  class="hover:filter hover:brightness-[80%]" />
                  </.link>
                <% end %>
              <% end %>
            </p>
          <% end %>
        </div>
        <hr />
        <div class="flex gap-x-2 mt-2 h-[28px]" >
          <%= for tag <- @job.career_fields do %>
            <p class={"border rounded-full p-1 text-xs lg:text-sm text-#{tag.name_en}-dark bg-#{tag.name_en}-light"}><%= tag.name_ja %></p>
          <% end %>
        </div>
      </div>
    </.link>
    """
  end

  @impl true
  def update(assigns, socket) do
    jobs = Jobs.list_jobs_group_by_career_field_and_rank(assigns.career_field.name_en)
    index = @rank |> Enum.find_index(&(&1 == assigns.job.rank))

    ranks = [
      Enum.at(@rank, index),
      Enum.at(@rank, index + 1)
    ]

    socket
    |> assign(assigns)
    |> assign(:rank, @rank)
    |> assign(:ranks, ranks)
    |> assign(:jobs, jobs)
    |> assign(:career_fields, [assigns.career_field])
    |> then(&{:ok, &1})
  end

  def filter_job(jobs, career_field, rank, filter) do
    if rank in [:entry, :basic] && career_field.name_en == "engineer" do
      jobs
      |> Map.get(career_field.name_en, %{})
      |> Map.get(rank, [])
      |> Enum.filter(&String.match?(&1.name, ~r/#{filter}/))
    else
      jobs
      |> Map.get(career_field.name_en, %{})
      |> Map.get(rank, [])
    end
  end

  defp icon_base_path(file), do: "/images/common/icons/#{file}"
  defp icon_path(:none), do: icon_base_path("gemGray.svg")
  defp icon_path(:beginner), do: icon_base_path("jemLow.svg")
  defp icon_path(:normal), do: icon_base_path("jemMiddle.svg")
  defp icon_path(:skilled), do: icon_base_path("jemHigh.svg")
end
