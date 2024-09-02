defmodule BrightWeb.OnboardingLive.JobRouteComponents do
  use BrightWeb, :live_component

  alias Bright.Jobs
  alias Bright.Jobs.Job

  import BrightWeb.OnboardingLive.JobPanelComponents, only: [locked_job: 1, unlocked_job: 1]

  @rank Ecto.Enum.values(Job, :rank)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row bg-white rounded w-full h-[420px] lg:h-full overflow-scroll order-2 lg:p-4 lg:mt-0 lg:order-1">
      <%= for career_field <- @career_fields do %>
        <div id={career_field.name_en} class="flex">
          <%= for rank <- @ranks do %>
            <% jobs = filter_job(@jobs, career_field, rank, @filter) %>
            <div class="mr-2 lg:mr-4 flex flex-col w-1/2 lg:w-full">
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
end
