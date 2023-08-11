defmodule BrightWeb.OnboardingLive.SkillPanels do
  use BrightWeb, :live_view

  alias Bright.{CareerWants, Repo}

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
            <section class={"bg-#{career_field.name_en}-dazzle mt-4 px-4 py-4 w-[1040px]"}>
              <p class="font-bold"><%= career_field.name_ja %>向けのスキル</p>
              <ul class="flex flex-wrap mt-2 gap-4">
                <!-- スキル ここから -->
                <%= for skill_panel <- get_career_job_skill_panels(jobs) do %>
                  <li>
                    <.link
                      navigate={"/onboardings/wants/#{@wants_id}/skill_panels/#{skill_panel.id}"}
                      class={[
                        "bg-#{career_field.name_en}-dark border-#{career_field.name_en}-dark",
                        "block border border-solid cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50"
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
  def mount(%{"id" => id}, _session, socket) do
    career_fields =
      CareerWants.get_career_want!(id)
      |> Repo.preload(jobs: [:career_fields, :skill_panels])
      |> Map.get(:jobs)
      |> Enum.group_by(fn job ->
        job.career_fields |> List.first()
      end)

    socket
    |> assign(:wants_id, id)
    |> assign(:career_fields, career_fields)
    |> then(&{:ok, &1})
  end

  def get_career_job_skill_panels(jobs) do
    Enum.reduce(jobs, [], fn job, acc ->
      acc ++ job.skill_panels
    end)
  end
end
