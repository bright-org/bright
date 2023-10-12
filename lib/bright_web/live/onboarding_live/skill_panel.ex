defmodule BrightWeb.OnboardingLive.SkillPanel do
  use BrightWeb, :live_view

  alias Bright.{Repo, SkillPanels, UserSkillPanels, Onboardings}
  alias Bright.Onboardings.UserOnboarding

  import BrightWeb.OnboardingLive.Index, only: [hidden_more_skills: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <section class="bg-white pt-6 pb-24 px-8 lg:py-8 min-h-[720px] relative rounded-lg">
      <h1 class={["font-bold text-3xl",hidden_more_skills(@current_path)] }>
        <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
          スキルを選ぶ
        </span>
      </h1>

      <div class="mt-0 lg:mt-8">
        <!-- スキルセクション　ここから -->
        <section>
          <h2 class="font-bold text-base lg:text-xl"><%= "#{@skill_panel.name} に含まれるスキル" %></h2>
          <!-- スキルWebアプリ開発セクション　ここから -->
          <section class="mt-1 lg:px-4 py-4 w-full lg:w-[1040px]">
            <ul>
              <%= for skill_unit <- @skill_units do %>
              <li>
                <span class={"bg-#{@career_field.name_en}-dazzle block mt-3 px-4 py-2 rounded select-none text-base w-full before:relative before:top-[3px] before:bg-bgGem#{String.capitalize(@career_field.name_en)} before:bg-5 before:bg-left before:bg-no-repeat before:content-[''] before:h-5 before:inline-block before:mr-1 before:w-5"}>
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

      <p class="flex flex-col lg:flex-row gap-y-4 lg:gap-y-0 justify-center mt-8 lg:px-4 w-full lg:w-[1040px]">
        <button
          phx-click={JS.push("select_skill_panel", value: %{id: @skill_panel.id, name: @skill_panel.name, type: "input"})}
          class="bg-brightGray-900 border border-solid border-brightGray-900 font-bold px-4 py-2 rounded select-none text-white w-full lg:w-64 hover:opacity-50"
        >
          このスキルでスキル入力に進む
        </button>

        <!-- αは落とす
        <button
          phx-click={JS.push("select_skill_panel", value: %{id: @skill_panel.id, name: @skill_panel.name, type: "skillup"})}
          class="bg-brightGray-900 border border-solid border-brightGray-900 font-bold ml-4  px-4 py-2 rounded select-none text-white w-full lg:w-64 hover:opacity-50"
        >
          このスキルでスキルアップに進む
        </button>
        -->

        <.link
          navigate={@return_to}
          class="bg-white block border border-solid border-black font-bold lg:ml-16 px-4 py-2 rounded select-none text-black text-center w-full lg:w-40 hover:opacity-50"
        >
          戻る
        </.link>
      </p>
    </section>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    skill_panel =
      SkillPanels.get_skill_panel!(id)
      |> Repo.preload(jobs: :career_fields)

    career_fields =
      skill_panel.jobs
      |> List.first()
      |> Map.get(:career_fields)

    skill_class = SkillPanels.get_skill_class_by_skill_panel_id(id)

    socket
    |> assign(:page_title, "スキルを選ぶ")
    |> assign(:skill_panel, skill_panel)
    |> assign(:career_field, List.first(career_fields))
    |> assign(:skill_units, skill_class.skill_units)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(%{"job_id" => job_id}, uri, socket) do
    path = URI.parse(uri).path |> Path.split() |> Enum.at(1)

    socket
    |> assign(:current_path, path)
    |> assign(:return_to, "/#{path}/jobs/#{job_id}")
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_params(%{"want_id" => want_id}, uri, socket) do
    path = URI.parse(uri).path |> Path.split() |> Enum.at(1)

    socket
    |> assign(:current_path, path)
    |> assign(:return_to, "/#{path}/wants/#{want_id}")
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event(
        "select_skill_panel",
        %{"id" => skill_panel_id, "name" => name},
        %{assigns: %{current_user: user}} = socket
      ) do
    finish_onboarding(user.user_onboardings, user.id, skill_panel_id)
    select_skill_panel(user.id, skill_panel_id)

    socket
    |> put_flash(:info, "スキルパネル:#{name}を取得しました")
    |> redirect(to: "/panels/#{skill_panel_id}")
    |> then(&{:noreply, &1})
  end

  defp select_skill_panel(user_id, skill_panel_id) do
    # 一度取得したスキルパネルを再度選択してもエラーにしないためにUnique indexの例外を握りつぶす
    try do
      UserSkillPanels.create_user_skill_panel(%{
        user_id: user_id,
        skill_panel_id: skill_panel_id
      })
    rescue
      Ecto.ConstraintError -> :ok
    end
  end

  defp finish_onboarding(nil, user_id, skill_panel_id) do
    {:ok, _onboarding} =
      Onboardings.create_user_onboarding(%{
        completed_at: NaiveDateTime.utc_now(),
        user_id: user_id,
        skill_panel_id: skill_panel_id
      })
  end

  defp finish_onboarding(%UserOnboarding{}, _, _), do: false
end
