defmodule BrightWeb.OnboardingLive.WantsJobComponents do
  use BrightWeb, :live_component

  alias Bright.{Jobs, CareerFields, Repo}
  alias Bright.Jobs.Job

  @rank %{expert: "高度", advanced: "応用", basic: "基本"}

  def render(assigns) do
    ~H"""
    <div id="wants_job_panel" class="hidden px-4 py-4">
      <!-- タブここから -->
      <aside id="select_job">
        <ul class="flex relative">
          <%= for career_field <- @career_fields do %>
            <li
              class={
                  "cursor-pointer select-none py-2 rounded-tl text-center w-40 " <>
                  if @selected_career.name_en == career_field.name_en,
                    do: "bg-#{career_field.name_en}-dark text-white",
                    else: "bg-#{career_field.name_en}-dazzle hover:bg-#{career_field.name_en}-dark hover:opacity-50 text-brightGray-200"
                }
              style={
                if @selected_career.name_en == career_field.name_en,
                    do: "background-color:#{@colors[career_field.name_en][:dark]};",
                    else: "background-color:#{@colors[career_field.name_en][:dazzle]};"

              }
              phx-click={JS.push("tab_click", target: @myself, value: %{id: career_field.id})}
            >
              <%= career_field.name_ja %>
            </li>
          <% end %>
          <li>
            <a
              href="#"
              class="absolute bg-brightGreen-300 block cursor-pointer font-bold select-none py-2 right-0 rounded text-center text-white -top-1.5 w-48 hover:opacity-50"
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
          style={"background-color:#{@colors[@selected_career.name_en][:dazzle]};"}
        >
          <%= for rank <- Ecto.Enum.values(Job, :rank) do %>
          <div class="mb-8">
            <p class="font-bold"><%= @rank[rank] %></p>
            <ul class="flex flex-wrap gap-4 mt-2">

              <% jobs = Map.get(@jobs, @selected_career.name_en, %{}) %>
              <%= for job <- Map.get(jobs, rank, []) do %>
              <li>
                <.link navigate={"/onboardings/jobs/#{job.id}"} class="block">
                  <label
                    class={"bg-#{@selected_career.name_en}-dark block border border-solid border-#{@selected_career.name_en}-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"}
                    style={"background-color:#{@colors[@selected_career.name_en][:dark]};"}
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

  def mount(socket) do
    career_fields = CareerFields.list_career_fields()

    jobs =
      Jobs.list_jobs()
      |> Repo.preload(:career_fields)
      |> Enum.group_by(&List.first(&1.career_fields).name_en)
      |> Enum.reduce(%{}, fn {key, value}, acc ->
        Map.put(acc, key, Enum.group_by(value, & &1.rank))
      end)

    socket
    # tailwindの色情報が壊れるので応急処置でconfigから読み込み
    |> assign(:colors, Application.fetch_env!(:bright, :career_field_colors))
    |> assign(:rank, @rank)
    |> assign(:career_fields, career_fields)
    |> assign(:selected_career, Enum.at(career_fields, 0))
    |> assign(:jobs, jobs)
    |> then(&{:ok, &1})
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> then(&{:ok, &1})
  end

  def handle_event(
        "tab_click",
        %{"id" => career_field_id},
        %{assigns: %{career_fields: career_fields}} = socket
      ) do
    socket
    |> assign(:selected_career, Enum.find(career_fields, fn c -> c.id == career_field_id end))
    |> then(&{:noreply, &1})
  end
end
