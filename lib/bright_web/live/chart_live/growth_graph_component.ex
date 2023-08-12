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
            <button phx-target={@myself} phx-click={JS.push("month_subtraction_click", value: %{id: "myself" })} class="w-11 h-9 bg-brightGray-900 flex justify-center items-center rounded bottom-1 absolute">
              <span class="material-icons text-white !text-4xl">arrow_left</span>
            </button>
          </div>
            <.growth_graph data={@data} id="growth-graph"/>
          <div class="ml-5 flex flex-col relative text-xl text-brightGray-500 text-bold">
            <p class="py-5">ベテラン</p>
            <p class="py-20">平均</p>
            <p class="py-6">見習い</p>
            <button phx-target={@myself} phx-click={JS.push("month_add_click", value: %{id: "myself" })} class="w-11 h-9 bg-brightGray-300 flex justify-center items-center rounded bottom-1 absolute">
              <span class="material-icons text-white !text-4xl">arrow_right</span>
            </button>
          </div>
        </div>
        <.timeline_bar
          id="myself"
          target={@myself}
          type="myself"
          dates={@data.labels}
          selected_date={@data.myselfSelected}
          display_now
        />
        <div class="flex py-4">
          <div class="w-14"></div>
          <div class="w-[725px] flex justify-between items-center">
            <div class="text-left flex items-center text-base hover:bg-brightGray-50">
            <%# TODO 他者選択できるまで非表示 %>
              <a :if={false} class="inline-flex items-center border border-brightGray-200 px-3 py-1 rounded">
                <img class="inline-block h-10 w-10 rounded-full" src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80" />
                <div>
                  <p>nokichi</p>
                  <p class="text-brightGray-300">アプリエンジニア</p>
                </div>
              </a>
            </div>
            <%# TODO 他者選択できるまで非表示 %>
            <button
              type="button"
              class="text-brightGray-600 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
            >
              ロールモデルに固定
            </button>
          </div>
          <div></div>
        </div>

        <%# TODO 他者選択できるまで非表示 %>
        <.timeline_bar
          :if={false}
          id="other"
          target={@myself}
          type="other"
          dates={["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"]}
          selected_date="2022.12"
        />
      </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    start =
      get_future_month(12, 2023, 8)
      |> Timex.shift(years: -1)

    socket =
      socket
      |> assign(assigns)
      |> assign(
        :data,
        create_data(assigns.user_id, assigns.skill_panel_id, assigns.class, %{
          year: start.year,
          month: start.month
        })
      )

    {:ok, socket}
  end

  defp get_future_month(start_month, year, month) do
    now_month = {year, month, 1} |> Date.from_erl!()

    1..24//3
    |> Enum.map(fn x -> x + start_month - 1 end)
    |> Enum.map(fn x -> month_shiht_add(year - 1, x) end)
    |> Enum.map(fn x -> Date.from_erl!(x) end)
    |> Enum.filter(fn x -> Timex.compare(x, now_month) > 0 end)
    |> List.first()
  end

  defp month_shiht_add(year, month) when month > 24, do: {year + 2, month - 24, 1}
  defp month_shiht_add(year, month) when month > 12, do: {year + 1, month - 12, 1}
  defp month_shiht_add(year, month) when month <= 12, do: {year, month, 1}

  @impl true
  def handle_event("timeline_bar_button_click", params, socket) do
    Process.send(self(), %{event_name: "timeline_bar_button_click", params: params}, [])
    socket = socket |> select_data(params["date"])
    {:noreply, socket}
  end

  def handle_event("month_subtraction_click", _params, socket) do
    {:noreply, create_labels(socket, -3)}
  end

  def handle_event("month_add_click", _params, socket) do
    {:noreply, create_labels(socket, 3)}
  end

  defp create_labels(socket, diff) do
    [year, month] =
      socket.assigns.data.labels
      |> List.first()
      |> String.split(".")

    labels = create_months(String.to_integer(year), String.to_integer(month), diff)

    data =
      socket.assigns.data
      |> Map.put(:labels, labels)

    assign(socket, :data, data)
  end

  defp create_data(user_id, skill_panel_id, class, start_month) do
    now = SkillScores.get_class_score(user_id, skill_panel_id, class) |> get_now()

    %{
      labels: create_months(start_month.year, start_month.month, 0),
      # role: [10, 20, 50, 60, 75, 100],
      # myself: [nil, 0, 35, 45, 55, 65],
      myself: [nil, 0, 0, 0, 0, 0],
      # other: [10, 10, 25, 35, 45, 70],
      now: now,
      myselfSelected: "now"
      # otherSelected: "2022.12"
    }
  end

  defp create_months(year, month, shift_month) do
    st =
      {year, month, 1}
      |> Date.from_erl!()
      |> Timex.shift(months: shift_month)

    0..4
    |> Enum.map(fn x ->
      Timex.shift(st, months: 3 * x) |> then(fn x -> "#{x.year}.#{x.month}" end)
    end)
  end

  defp select_data(socket, date) do
    data =
      socket.assigns.data
      |> Map.put(:myselfSelected, date)

    assign(socket, :data, data)
  end

  defp get_now(%{percentage: now}), do: now
  defp get_now(nil), do: 0
end
