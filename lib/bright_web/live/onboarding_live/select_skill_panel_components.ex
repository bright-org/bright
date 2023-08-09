defmodule BrightWeb.OnboardingLive.SelectSkillPanelComponents do
  use BrightWeb, :live_component

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
          <%= for {career_field_id, career_field} <- @career_fields do %>
            <section class={"bg-#{career_field.name_en}-dazzle mt-4 px-4 py-4 w-[1040px]"}>
              <p class="font-bold"><%= career_field.name_ja %>向けのスキル</p>
              <ul class="flex flex-wrap mt-2 gap-4">
                <!-- スキル ここから -->
                <%= for skill_panel <- Map.get(@skill_panels_by_career_fields, career_field_id, []) do %>
                  <li>
                    <button
                      onclick={"location.href='/onboardings/select_skill_result/#{skill_panel.skill_panel_id}'"}
                      class={[
                        "bg-#{career_field.name_en}-dark border-#{career_field.name_en}-dark",
                        "block border border-solid cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50"
                        ]}
                      >
                      <%= skill_panel.name %>
                    </button>
                  </li>
                <% end %>
              </ul>
            </section>
          <% end %>
        </section>
        <!-- スキルセクション ここまで -->
      </div>

      <p class="mt-8">
        <button
          onclick="location.href='/onboardings'"
          class="bg-white block border border-solid border-black font-bold mt-4 mx-auto px-4 py-2 rounded select-none text-black w-40 hover:opacity-50"
        >
          戻る
        </button>
      </p>
    </section>
    """
  end

  @impl true
  def mount(socket) do
    socket
    |> assign(:career_fields, [])
    |> then(&{:ok, &1})
  end
end
