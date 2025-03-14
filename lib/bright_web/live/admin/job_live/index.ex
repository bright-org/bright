defmodule BrightWeb.Admin.JobLive.Index do
  use BrightWeb, :live_view

  alias Bright.Jobs
  alias Bright.Jobs.Job
  alias Bright.CareerGroups

  @impl true
  def mount(_params, _session, socket) do
    jobs = Jobs.list_jobs_group_by_career_field_and_rank(:all)

    career_groups =
      CareerGroups.list_career_groups_with_career_field(:all)
      |> Enum.concat([
        %{career_fields: [%{name_en: "other", name_ja: "その他"}]}
      ])

    socket
    |> assign(:jobs, jobs)
    |> assign(:career_groups, career_groups)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Job")
    |> assign(:job, Jobs.get_job!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Job")
    |> assign(:job, %Job{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Jobs")
    |> assign(:job, nil)
  end

  @impl true
  def handle_info({BrightWeb.Admin.JobLive.FormComponent, {:saved, _job}}, socket) do
    {:noreply, assign(socket, :jobs, Jobs.list_jobs_group_by_career_field_and_rank(:all))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    job = Jobs.get_job!(id)
    {:ok, _} = Jobs.delete_job(job)

    {:noreply, assign(socket, :jobs, Jobs.list_jobs_group_by_career_field_and_rank(:all))}
  end

  def rank_jobs(assigns) do
    ~H"""
    <div class="my-8">
      <p class="text-left text-brightGray-400 text-xl"><%= @rank_list[@rank] %></p>
      <hr class="h-[2px] bg-brightGray-50 mb-4" />
      <div class="flex flex-wrap justify-center mt-2 lg:justify-start">
        <% jobs = Map.get(@jobs, @career_field.name_en, %{}) %>
        <%= for job <- Map.get(jobs, @rank, []) do %>
        <div id={"jobs-#{job.id}"} class="border m-1">
            <div
              class={"px-2 rounded w-[150px] lg:w-[340px] min-h-[100px] lg:min-h-[74px] flex flex-col"}
            >
              <div class="flex flex-col lg:flex-row justify-between mt-2 mb-[4px]">
                <p class="text-xs lg:w-44 lg:font-bold lg:mt-1 mb-1 lg:mb-0"><%= job.name %></p>
                <.link navigate={~p"/admin/jobs/#{job}"}>Show</.link>
                <.link patch={~p"/admin/jobs/#{job}/edit"}>Edit</.link>
                <.link
                    phx-click={JS.push("delete", value: %{id: job.id})}
                    data-confirm="Are you sure?"
                >Delete</.link>
              </div>
              <hr />
              <div class="flex justify-between">
                <div class="flex-row">
                  <%= for panel <- job.skill_panels do %>
                  <p><%= panel.name %></p>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
