defmodule BrightWeb.OnboardingLive.WantsJobComponents do
  use BrightWeb, :live_component

  alias Bright.{Jobs, CareerFields}
  alias Bright.Jobs.Job
  @rank %{expert: "高度", advanced: "応用", basic: "基本"}

  def render(assigns) do
    ~H"""
    <section class="accordion flex mt-8 max-w-[1236px]">
      <div class="bg-brightGray-50 rounded w-full">
        <p
          class={
            "bg-brightGray-900 cursor-pointer font-bold px-4 py-2 relative rounded select-none text-white hover:opacity-50 before:absolute before:block before:border-l-2 before:border-t-2 before:border-solid before:content-[''] before:h-3 before:right-4 before:top-1/2 before:w-3 " <>
            if @open_panel, do: open(), else: close()
          }
          phx-click={toggle("#wants_job_panel")}
          phx-target={@myself}
        >
          現在のジョブ、または、なりたいジョブからスキルを選ぶ
        </p>

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
                        else: "bg-#{career_field.name_en}-dazzle hover:bg-#{career_field.name_en}-dark text-brightGray-200 hover:text-white"
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
            <section class={"bg-#{@selected_career.name_en}-dazzle px-4 py-4"}>
              <%= for rank <- Ecto.Enum.values(Job, :rank) do %>
              <div class="mb-8">
                <p class="font-bold"><%= @rank[rank] %></p>
                <ul class="flex flex-wrap gap-4 mt-2">

                  <% jobs = Map.get(@jobs, @selected_career.name_en, %{}) %>
                  <%= for job <- Map.get(jobs, rank, []) do %>
                  <li>
                    <label
                      class={"bg-#{@selected_career.name_en}-dark block border border-solid border-#{@selected_career.name_en}-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"}
                    >
                      <%= job.name %>
                    </label>
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
      </div>
    </section>
    """
  end

  def mount(socket) do
    career_fields = CareerFields.list_career_fields()

    jobs =
      Jobs.list_jobs()
      |> Enum.group_by(& &1.career_field.name_en)
      |> Enum.reduce(%{}, fn {key, value}, acc ->
        Map.put(acc, key, Enum.group_by(value, & &1.rank))
      end)

    socket
    |> assign(:open_panel, false)
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

  def handle_event("toggle_panel", _params, %{assigns: %{open_panel: open}} = socket) do
    {:noreply, assign(socket, :open_panel, !open)}
  end

  defp toggle(js \\ %JS{}, id) do
    js
    |> JS.push("toggle_panel")
    |> JS.toggle(to: id)
  end

  defp close(),
    do: "before:-mt-2 before:rotate-225"

  defp open(),
    do: "rounded-bl-none rounded-br-none before:-mt-0.5 before:rotate-45"
end
