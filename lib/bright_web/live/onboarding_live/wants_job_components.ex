defmodule BrightWeb.OnboardingLive.WantsJobComponents do
  use BrightWeb, :live_component

  alias Bright.{Jobs, CareerFields}
  alias Bright.Jobs.Job

  @rank %{entry: "入門", basic: "基本", advanced: "応用", expert: "高度"}

  @impl true
  def render(assigns) do
    ~H"""
    <div id="wants_job_panel" class="hidden px-4 py-4">
      <!-- タブここから -->
      <aside id="select_job">
        <ul class="flex relative text-xs">
          <%= for career_field <- @career_fields do %>
            <li
              class={
                  "cursor-pointer select-none py-2 text-center w-40 " <>
                  add_edge_style(@career_fields, career_field) <>
                  if @selected_career.name_en == career_field.name_en,
                    do: "bg-#{career_field.name_en}-dark text-white",
                    else: "bg-#{career_field.name_en}-dazzle hover:bg-#{career_field.name_en}-dark text-brightGray-200 hover:text-white"
                }
              phx-click={JS.push("tab_click", target: @myself, value: %{id: career_field.id})}
            >
              <%= career_field.name_ja %>
            </li>
          <% end %>
          <!-- αは落とす -->
          <li :if={false}>
            <a
              href="#"
              class="absolute bg-brightGray-900 block cursor-pointer font-bold select-none py-2 right-0 rounded text-center text-white -top-1.5 w-48 hover:opacity-50"
            >
              キャリアパスを見直す
            </a>
          </li>
        </ul>
      </aside>
      <!-- タブここまで -->

      <!-- ジョブセクションここから -->
      <section>
        <%= if @selected_career do %>
        <section
          class={"bg-#{@selected_career.name_en}-dazzle px-4 py-4"}
        >
          <%= for rank <- Ecto.Enum.values(Job, :rank) do %>
          <div class="mb-8">
            <p class="font-bold text-center lg:text-left"><%= @rank[rank] %></p>
            <ul class="flex flex-wrap gap-4 justify-center mt-2 lg:justify-start">

              <% jobs = Map.get(@jobs, @selected_career.name_en, %{}) %>
              <%= for job <- Map.get(jobs, rank, []) do %>
              <li>
                <.link navigate={"#{@current_path}/jobs/#{job.id}"} class="block">
                  <label
                    class={"bg-#{@selected_career.name_en}-dark block border border-solid border-#{@selected_career.name_en}-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"}
                  >
                    <%= job.name %>
                  </label>
                </.link>
              </li>
              <% end %>
              <!-- ジョブここまで -->
            </ul>
          </div>
          <% end %>
        </section>
        <% end %>
      </section>
      <!-- ジョブセクション ここまで -->
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
  def update(%{tab: tab} = assigns, socket) do
    career_fields = CareerFields.list_career_fields()

    socket
    |> assign(assigns)
    |> assign(:career_fields, career_fields)
    |> assign(:selected_career, Enum.find(career_fields, &(&1.name_en == tab)))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => career_field_id},
        %{assigns: %{career_fields: career_fields}} = socket
      ) do
    socket
    |> assign(:selected_career, Enum.find(career_fields, fn c -> c.id == career_field_id end))
    |> then(&{:noreply, &1})
  end

  defp add_edge_style(career_fields, career_field) do
    index = Enum.find_index(career_fields, &(&1 == career_field))

    case index do
      0 -> "rounded-tl "
      3 -> "rounded-tr "
      _ -> ""
    end
  end
end
