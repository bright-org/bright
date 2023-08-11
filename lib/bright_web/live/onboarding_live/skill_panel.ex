defmodule BrightWeb.OnboardingLive.SkillPanel do
  use BrightWeb, :live_view

  alias Bright.{Repo, SkillPanels, UserSkillPanels}

  @impl true
  def render(assigns) do
    ~H"""
    <section class="bg-white p-8 min-h-[720px] relative rounded-lg">
      <h1 class="font-bold text-3xl">
        <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
          スキルを選ぶ
        </span>
      </h1>

      <div class="mt-8">
        <!-- スキルセクション　ここから -->
        <section>
          <h2 class="font-bold text-xl">ベースになるスキルは以下となります</h2>
          <!-- スキルWebアプリ開発セクション　ここから -->
          <section class="mt-1 px-4 py-4 w-[1040px]">
            <ul>
              <%= for skill_unit <- @skill_units do %>
              <li>
                <span class={"bg-#{@career_field.name_en}-dazzle block mt-3 px-4 py-2 rounded select-none text-base w-full before:relative before:top-[3px] before:bg-bgGemEngineer before:bg-5 before:bg-left before:bg-no-repeat before:content-[''] before:h-5 before:inline-block before:mr-1 before:w-5"}>
                  <%= skill_unit.name %>
                </span>
              </li>
              <% end %>
            </ul>
          </section>
          <!-- スキルデスクトップアプリ開発セクションセクション　ここまで -->
        </section>
        <!-- スキルセクション　ここまで -->
      </div>

      <p class="flex justify-center mt-8 px-4 w-[1040px]">
        <button
          phx-click={JS.push("select_skill_panel", value: %{id: @skill_panel.id, name: @skill_panel.name})}
          class="bg-brightGray-900 border border-solid border-brightGray-900 font-bold px-4 py-2 rounded select-none text-white w-65 hover:opacity-50"
        >
          このスキルでスキル入力に進む
        </button>

        <!-- αは落とす
        <button class="bg-brightGray-900 border border-solid border-brightGray-900 font-bold ml-4  px-4 py-2 rounded select-none text-white w-65 hover:opacity-50">
          このスキルでスキルアップに進む
        </button>
        -->

        <.link
          navigate={"/onboardings/wants/#{@wants_id}"}
          class="bg-white block border border-solid border-black font-bold ml-16 px-4 py-2 rounded select-none text-black text-center w-40 hover:opacity-50"
        >
          戻る
        </.link>
      </p>
    </section>
    """
  end

  @impl true
  def mount(%{"career_want_id" => wants_id, "id" => id}, _session, socket) do
    skill_panel =
      SkillPanels.get_skill_panel!(id)
      |> Repo.preload(jobs: :career_fields)

    career_fields =
      skill_panel.jobs
      |> List.first()
      |> Map.get(:career_fields)

    skill_class = SkillPanels.get_skill_class_by_skill_panel_id(id)

    socket
    |> assign(:skill_panel, skill_panel)
    |> assign(:career_field, List.first(career_fields))
    |> assign(:wants_id, wants_id)
    |> assign(:skill_units, skill_class.skill_units)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("select_skill_panel", %{"id" => skill_panel_id, "name" => name}, socket) do
    UserSkillPanels.create_user_skill_panel(%{
      user_id: socket.assigns.current_user.id,
      skill_panel_id: skill_panel_id
    })

    socket
    |> put_flash(:info, "スキルパネル:#{name}を取得しました")
    |> push_navigate(to: "/panels/#{skill_panel_id}/graph")
    |> then(&{:noreply, &1})
  end
end
