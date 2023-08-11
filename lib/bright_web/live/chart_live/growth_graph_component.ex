defmodule BrightWeb.ChartLive.GrowthGraphComponent do
  @moduledoc """
  Growth Graph Component
  """
  use BrightWeb, :live_component
  import BrightWeb.ChartComponents
  import BrightWeb.TimelineBarComponents
  alias Bright.SkillScores

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-[880px] flex flex-col">
      <!-- グラフ -->
      <div class="ml-auto mr-28 mt-6 mb-1">
          <button
            type="button"
            class="text-brightGray-600 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
          >
            ロールモデルを解除
          </button>
        </div>
        <div class="flex">
          <div class="w-14 relative">
            <button class="w-11 h-9 bg-brightGray-900 flex justify-center items-center rounded bottom-1 absolute">
              <span class="material-icons text-white !text-4xl">arrow_left</span>
            </button>
          </div>
            <.growth_graph data={@data} id="growth-graph"/>
          <div class="ml-5 flex flex-col relative text-xl text-brightGray-500 text-bold">
            <p class="py-5">ベテラン</p>
            <p class="py-20">平均</p>
            <p class="py-6">見習い</p>
            <button class="w-11 h-9 bg-brightGray-300 flex justify-center items-center rounded bottom-1 absolute">
              <span class="material-icons text-white !text-4xl"
                >arrow_right</span>
            </button>
          </div>
        </div>
        <.timeline_bar
          id="myself"
          type="myself"
          dates={["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"]}
          selected_date="2023.6"
          display_now
        />
        <div class="flex py-4">
          <div class="w-14"></div>
          <div class="w-[725px] flex justify-between items-center">
            <div class="text-left flex items-center text-base hover:bg-brightGray-50">
              <a class="inline-flex items-center border border-brightGray-200 px-3 py-1 rounded">
                <img class="inline-block h-10 w-10 rounded-full" src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80" />
                <div>
                  <p>nokichi</p>
                  <p class="text-brightGray-300">アプリエンジニア</p>
                </div>
              </a>
            </div>
            <button
              type="button"
              class="text-brightGray-600 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
            >
              ロールモデルに固定
            </button>
          </div>
          <div></div>
        </div>

        <.timeline_bar
          id="other"
          type="other"
          dates={["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"]}
          selected_date="2022.12"
        />
      </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:data, create_data(assigns.user_id, assigns.skill_panel_id, assigns.class))

    {:ok, socket}
  end

  defp create_data(user_id, skill_panel_id, class) do
    now = SkillScores.get_class_score(user_id, skill_panel_id, class) |> get_now()

    %{
      labels: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
      # role: [10, 20, 50, 60, 75, 100],
      # myself: [nil, 0, 35, 45, 55, 65],
      myself: [nil, 0, 0, 0, 0, 0],
      # other: [10, 10, 25, 35, 45, 70],
      now: now,
      myselfSelected: "2023.6"
      # otherSelected: "2022.12"
    }
  end

  defp get_now(%{percentage: now}), do: now
  defp get_now(nil), do: 0
end
