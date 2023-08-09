defmodule BrightWeb.OnboardingLive.SelectSkillResultComponents do
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

      <div class="mt-8">
        <!-- スキルセクション　ここから -->
        <section>
          <h2 class="font-bold text-xl">ベースになるスキルは以下となります</h2>
          <!-- スキルWebアプリ開発セクション　ここから -->
          <section class="mt-1 px-4 py-4 w-[1040px]">
            <ul>
              <%= for skill_unit_name <- @skill_units do %>
              <li>
                <span class={"bg-#{@career_field_name_en}-dazzle block mt-3 px-4 py-2 rounded select-none text-base w-full before:relative before:top-[3px] before:bg-bgGemEngineer before:bg-5 before:bg-left before:bg-no-repeat before:content-[''] before:h-5 before:inline-block before:mr-1 before:w-5"}>
                  <%= skill_unit_name %>
                </span>
              </li>
              <% end %>
            </ul>
          </section>
          <!-- スキルデスクトップアプリ開発セクションセクション　ここまで -->
        </section>
        <!-- スキルセクション　ここまで -->
      </div>

      <p class="flex justify-center mt-8 px-4">
        <button class="bg-brightGray-900 border border-solid border-brightGray-900 font-bold px-4 py-2 rounded select-none text-white w-65 hover:opacity-50">
          このスキルでスキル入力に進む
        </button>

        <button class="bg-brightGray-900 border border-solid border-brightGray-900 font-bold ml-4  px-4 py-2 rounded select-none text-white w-65 hover:opacity-50">
          このスキルでスキルアップに進む
        </button>

        <button
          onclick="location.href='/onboardings'"
          class="bg-white block border border-solid border-black font-bold ml-16 px-4 py-2 rounded select-none text-black w-40 hover:opacity-50"
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
    |> assign(:skill_units, [])
    |> then(&{:ok, &1})
  end
end
