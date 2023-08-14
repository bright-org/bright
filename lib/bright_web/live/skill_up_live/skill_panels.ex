defmodule BrightWeb.SkillUpLive.SkillPanels do
  use BrightWeb, :live_view

  alias Bright.{CareerWants, Jobs, UserSkillPanels, Repo}

  @impl true
  def render(assigns) do
    ~H"""
    <section class="bg-white p-8 min-h-[720px] relative rounded-lg">
      <h1 class="font-bold text-3xl">
        <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
          スキルを選ぶ
        </span>
      </h1>

      <div class="flex flex-col mt-4">
        <!-- スキルセクション ここから -->
        <section>
          <%= for {career_field, jobs} <- @career_fields do %>
           <%= if !Enum.empty?(jobs) do %>
            <section
              class={"bg-#{career_field.name_en}-dazzle mt-4 px-4 py-4 w-[1040px]"}
              style={"background-color: #{@colors[career_field.name_en][:dazzle]};"}
            >
              <p class="font-bold"><%= career_field.name_ja %>向けのスキル</p>
              <ul class="flex flex-wrap mt-2 gap-4">
                <!-- スキル ここから -->
                <%= for skill_panel <- get_career_job_skill_panels(jobs) do %>
                  <%= if Enum.member?(@exists_panel, skill_panel.id) do %>
                  <.link
                      class={[
                        "bg-#{career_field.name_en}-dark border-#{career_field.name_en}-dark",
                        "block border border-solid font-bold px-4 py-2 rounded select-none text-white text-center w-60 opacity-50"
                        ]}
                        style={"background-color: #{@colors[career_field.name_en][:dark]}; border-color: #{@colors[career_field.name_en][:dark]};"}
                      >
                      <%= skill_panel.name %>
                    </.link>

                  <% else %>
                  <li>
                    <.link
                      navigate={"/skill_up/#{@route}/#{@id}/skill_panels/#{skill_panel.id}"}
                      class={[
                        "bg-#{career_field.name_en}-dark border-#{career_field.name_en}-dark",
                        "block border border-solid cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50"
                        ]}
                        style={"background-color: #{@colors[career_field.name_en][:dark]}; border-color: #{@colors[career_field.name_en][:dark]};"}
                      >
                      <%= skill_panel.name %>
                    </.link>
                  </li>
                  <% end %>
                <% end %>
              </ul>
            </section>
            <% end %>
          <% end %>
        </section>
        <!-- スキルセクション ここまで -->
      </div>

      <p class="mt-8 w-[1040px]">
        <.link
          navigate="/onboardings"
          class=" self-center bg-white block border border-solid border-black font-bold mt-4 mx-auto px-4 py-2 rounded select-none text-black text-center w-40 hover:opacity-50"
        >
          戻る
        </.link>
      </p>
    </section>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: user}}=socket) do
    socket
    # tailwindの色情報が壊れるので応急処置でconfigから読み込み
    |> assign(:colors, Application.fetch_env!(:bright, :career_field_colors))
    |> assign(:exists_panel, UserSkillPanels.list_user_skill_panels_dev(user.id))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(%{"want_id" => id}, _uri, socket) do
    career_fields =
      CareerWants.get_career_want!(id)
      |> Repo.preload(jobs: [:career_fields, :skill_panels])
      |> Map.get(:jobs)
      |> Enum.group_by(fn job ->
        job.career_fields |> List.first()
      end)

    socket
    |> assign(:route, "wants")
    |> assign(:id, id)
    |> assign(:career_fields, career_fields)
    |> then(&{:noreply, &1})
  end

  def handle_params(%{"job_id" => id}, _uri, socket) do
    career_fields =
      Jobs.get_job!(id)
      |> Repo.preload([:career_fields, :skill_panels])
      |> then(&[&1])
      |> Enum.group_by(fn j -> j.career_fields |> List.first() end)

    socket
    |> assign(:route, "jobs")
    |> assign(:id, id)
    |> assign(:career_fields, career_fields)
    |> then(&{:noreply, &1})
  end

  def get_career_job_skill_panels(jobs) do
    Enum.reduce(jobs, [], fn job, acc ->
      acc ++ job.skill_panels
    end)
    |> Enum.uniq()
  end
end
