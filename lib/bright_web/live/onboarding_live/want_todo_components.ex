defmodule BrightWeb.OnboardingLive.WantToDoComponents do
  use BrightWeb, :live_component

  alias Bright.{Repo, CareerWants}

  @impl true
  def render(assigns) do
    ~H"""
    <div id="want_todo_panel" class="hidden">
      <ul class="flex flex-wrap gap-4 justify-center p-4 lg:justify-start">
        <!-- やりたいこと ここから -->
        <%= for wants <- @career_wants do %>
        <li class="bg-white px-4 py-4 rounded select-none w-72 hover:filter hover:brightness-90">
          <.link navigate={"#{@current_path}/wants/#{wants.id}"} class="block">
            <b class="block text-center"><%= wants.name %></b>
            <div class="flex flex-wrap gap-2 justify-center mt-2 py-2">
              <%= for career_field <- wants.jobs do %>
                <span
                  class={[
                      "px-2 py-0.5 rounded-full text-white text-xs",
                      "bg-#{career_field.name_en}-dark"
                    ]}
                  >
                  <%= career_field.name_ja %>
                </span>
              <% end %>
            </div>
          </.link>
        </li>
        <% end %>
      </ul>
      <!-- αは落とす -->
      <form class="flex flex-wrap gap-4 justify-start p-4" :if={false}>
        <input
          type="text"
          placeholder="やりたいことに関連するキーワードを入れてください"
          class="border border-solid border-black placeholder-brightGray-200 px-4 py-2 rounded-l w-[512px]"
        />
        <button class="bg-white border border-l-0 border-solid border-black font-bold -ml-4 px-4 py-2 rounded-r w-20 hover:filter hover:brightness-90">
          検索
        </button>
        <div class="w-full"><span class="px-4 text-brightGray-300">検索結果が表示されます。</span></div>
      </form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    career_wants =
      CareerWants.list_career_wants()
      |> Repo.preload(jobs: :career_fields)
      |> Enum.map(fn wants ->
        Map.put(
          wants,
          :jobs,
          Enum.map(wants.jobs, & &1.career_fields)
          |> List.flatten()
          |> Enum.uniq()
          |> Enum.sort_by(& &1.position)
        )
      end)

    socket
    |> assign(assigns)
    |> assign(:open_panel, false)
    |> assign(:career_wants, career_wants)
    |> then(&{:ok, &1})
  end
end
