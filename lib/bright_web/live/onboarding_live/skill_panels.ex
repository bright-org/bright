defmodule BrightWeb.OnboardingLive.SkillPanels do
  use BrightWeb, :live_view

  alias Bright.{CareerWants, Jobs}
  import BrightWeb.OnboardingLive.Index, only: [hidden_more_skills: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <section class="bg-white pt-2 px-8 lg:py-8 min-h-[720px] relative rounded-lg pb-28">
      <h1 class={["font-bold text-3xl", hidden_more_skills(@current_path)]}>
        <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
          スキルを選ぶ
        </span>
      </h1>

      <div class="flex flex-col mt-4">
        <!-- スキルセクション ここから -->
        <section>
          <%= for {career_field, skill_panels} <- @career_fields do %>
            <% skill_panels = Enum.uniq(skill_panels) %>
            <section
              :if={Enum.count(skill_panels) > 0}
              class={"bg-#{career_field.name_en}-dazzle mt-4 px-4 py-4 w-full lg:w-[1040px]"}
            >
              <p class="font-bold"><%= career_field.name_ja %>向けのスキル</p>
              <ul class="flex flex-wrap flex-col lg:flex-row mt-2 gap-4">
                <!-- スキル ここから -->
                <%= for skill_panel <- skill_panels do %>
                  <li>
                    <.link
                      navigate={"/#{@current_path}/#{@route}/#{@id}/skill_panels/#{skill_panel.id}"}
                      class={[
                        "bg-#{career_field.name_en}-dark border-#{career_field.name_en}-dark",
                        "block border border-solid cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-full lg:w-60 hover:opacity-50"
                      ]}
                    >
                      <%= skill_panel.name %>
                    </.link>
                  </li>
                <% end %>
              </ul>
            </section>
          <% end %>
        </section>
        <!-- スキルセクション ここまで -->
      </div>

      <p class="mt-8 w-full lg:w-[1040px]">
        <.link
          navigate={@return_to}
          class="self-start lg:self-center bg-white block border border-solid border-black font-bold mt-4 mx-auto px-4 py-2 rounded select-none text-black text-center w-full lg:w-40 hover:opacity-50"
        >
          戻る
        </.link>
      </p>
    </section>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "スキルを選ぶ")}
  end

  @impl true
  def handle_params(%{"want_id" => id}, uri, socket) do
    current_path = URI.parse(uri).path |> Path.split() |> Enum.at(1)
    career_fields = CareerWants.list_skill_panels_group_by_career_field(id)

    socket
    |> assign(:current_path, current_path)
    |> assign(:route, "wants")
    |> assign(:return_to, "/#{current_path}?open=want_todo_panel")
    |> assign(:id, id)
    |> assign(:career_fields, career_fields)
    |> then(&{:noreply, &1})
  end

  def handle_params(%{"job_id" => id}, uri, socket) do
    current_path = URI.parse(uri).path |> Path.split() |> Enum.at(1)
    career_fields = Jobs.list_skill_panels_group_by_career_field(id)

    case Map.keys(career_fields) |> List.first() do
      nil ->
        raise Ecto.NoResultsError, queryable: Bright.CareerFields.CareerField

      career_field ->
        socket
        |> assign(:current_path, current_path)
        |> assign(:route, "jobs")
        |> assign(:return_to, "/#{current_path}?open=wants_job_panel&tab=#{career_field.name_en}")
        |> assign(:id, id)
        |> assign(:career_fields, career_fields)
        |> then(&{:noreply, &1})
    end
  end
end
