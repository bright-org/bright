defmodule BrightWeb.OnboardingLive.WantToDoComponents do
  use BrightWeb, :live_component

  alias Bright.{Repo, CareerWants}

  # tailwindのカラーが壊れているので応急処置
  @colors %{
    "infra" => %{
      dark: "#51971a",
      dazzle: "#f2ffe1"
    },
    "engineer" => %{
      dark: "#165bc8",
      dazzle: "#eefbff"
    },
    "designer" => %{
      dark: "#e96500",
      dazzle: "#ffffdc"
    },
    "marketer" => %{
      dark: "#6b50a4",
      dazzle: "#f1e3ff"
    }
  }

  @impl true
  def render(assigns) do
    ~H"""
    <section class="accordion mt-5 max-w-[1236px]">
      <div class="bg-brightGray-50 rounded w-full">
        <p
          class={
            "bg-brightGray-900 cursor-pointer font-bold px-4 py-2 relative rounded select-none text-white hover:opacity-50 before:absolute before:block before:border-l-2 before:border-t-2 before:border-solid before:content-[''] before:h-3 before:right-4 before:top-1/2 before:w-3 " <>
            if @open_panel, do: open(), else: close()
          }
          phx-click={toggle("#wants_todo_panel")}
          phx-target={@myself}
        >
          やりたいことや興味・関心があることからスキルを選ぶ
        </p>

        <div id="wants_todo_panel" class="hidden">
          <ul class="flex flex-wrap gap-4 justify-start p-4">
            <!-- やりたいこと ここから -->
            <%= for wants <- @career_wants do %>
            <li class="bg-white px-4 py-4 rounded select-none w-72 hover:opacity-50">
              <.link navigate={"/onboardings/wants/#{wants.id}"} class="block">
                <b class="block text-center"><%= wants.name %></b>
                <div class="flex flex-wrap gap-2 justify-center mt-2 py-2">
                  <%= for career_field <- wants.skill_panels do %>
                    <span
                      class={[
                          "px-2 py-0.5 rounded-full text-white text-xs",
                          "bg-#{career_field.name_en}-dark"
                        ]}
                        style={"background-color: #{@colors[career_field.name_en][:dark]};"}
                      >
                      <%= career_field.name_ja %>
                    </span>
                  <% end %>
                </div>
              </.link>
            </li>
            <% end %>
          </ul>

          <form class="flex flex-wrap gap-4 justify-start p-4">
            <input
              type="text"
              placeholder="やりたいことに関連するキーワードを入れてください"
              class="border border-solid border-black placeholder-brightGray-200 px-4 py-2 rounded-l w-[512px]"
            />
            <button class="bg-white border border-l-0 border-solid border-black font-bold -ml-4 px-4 py-2 rounded-r w-20 hover:opacity-50">
              検索
            </button>
            <div class="w-full"><span class="px-4 text-brightGray-300">検索結果が表示されます。</span></div>
          </form>
        </div>
      </div>
    </section>
    """
  end

  @impl true
  def mount(socket) do
    career_wants =
      CareerWants.list_career_wants()
      |> Repo.preload(skill_panels: :career_fields)
      |> Enum.map(fn wants ->
        Map.put(
          wants,
          :skill_panels,
          Enum.map(wants.skill_panels, & &1.career_fields)
          |> List.flatten()
          |> Enum.uniq()
        )
      end)

    socket
    |> assign(:colors, @colors)
    |> assign(:open_panel, false)
    |> assign(:career_wants, career_wants)
    |> then(&{:ok, &1})
  end

  @impl true
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
