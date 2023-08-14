defmodule BrightWeb.ChartLive.GrowthGraphComponent do
  @moduledoc """
  Growth Graph Component
  """

  use BrightWeb, :live_component
  import BrightWeb.ChartComponents
  import BrightWeb.TimelineBarComponents
  alias Bright.SkillScores
  @start_year 2021
  @start_month 10

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-[880px] flex flex-col">
      <!-- グラフ -->
      <div class="ml-auto mr-28 mt-6 mb-1">
      <%# TODO 他者選択できるまで非表示 %>
          <button :if={false}
            type="button"
            class="text-brightGray-600 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
          >
            ロールモデルを解除
          </button>
        </div>
        <div class="flex">
          <div class="w-14 relative">
            <button
              :if={@data.past_enabled}
              phx-target={@myself}
              phx-click={JS.push("month_subtraction_click", value: %{id: "myself" })}
              class="w-11 h-9 bg-brightGray-900 flex justify-center items-center rounded bottom-1 absolute"
              disabled={false}
            >
              <span class="material-icons text-white !text-4xl">arrow_left</span>
            </button>
            <button
              :if={!@data.past_enabled}
              phx-target={@myself}
              class="w-11 h-9 bg-brightGray-300 flex justify-center items-center rounded bottom-1 absolute"
              disabled={true}
            >
            <span class="material-icons text-white !text-4xl">arrow_left</span>
          </button>

          </div>
            <.growth_graph data={@data} id="growth-graph"/>
          <div class="ml-5 flex flex-col relative text-xl text-brightGray-500 text-bold">
            <p class="py-5">ベテラン</p>
            <p class="py-20">平均</p>
            <p class="py-6">見習い</p>
            <button
              :if={@data.future_enabled}
              phx-target={@myself}
              class="w-11 h-9 bg-brightGray-300 flex justify-center items-center rounded bottom-1 absolute"
              disabled={true}
            >
              <span class="material-icons text-white !text-4xl">arrow_right</span>
            </button>
            <button
              :if={!@data.future_enabled}
              phx-target={@myself}
              phx-click={if !@data.future_enabled, do: JS.push("month_add_click", value: %{id: "myself" })}
              class="w-11 h-9 bg-brightGray-900 flex justify-center items-center rounded bottom-1 absolute"
              disabled={false}
            >
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
          display_now={@data.future_enabled}
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
            <button :if={false}
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
      get_future_month()
      |> Timex.shift(years: -1)

    socket =
      socket
      |> assign(assigns)

    labels = create_months(start.year, start.month, 0)

    socket =
      socket
      |> assign(:data, %{
        myselfSelected: "now",
        labels: labels,
        future_enabled: true,
        past_enabled: true
      })
      |> create_data()

    {:ok, socket}
  end

  defp get_future_month(), do: get_future_month(@start_month, Date.utc_today())

  defp get_future_month(start_month, now) do
    {:ok, now} = Date.new(now.year, now.month, 1)

    1..24//3
    |> Enum.map(fn x -> x + start_month - 1 end)
    |> Enum.map(fn x -> month_shiht_add(now.year - 1, x) end)
    |> Enum.map(fn x -> Date.from_erl!(x) end)
    |> Enum.filter(fn x -> Timex.compare(x, now) > 0 end)
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
    {:noreply, create_labels(socket, -3) |> create_data()}
  end

  def handle_event("month_add_click", _params, socket) do
    {:noreply, create_labels(socket, 3) |> create_data()}
  end

  defp create_labels(socket, diff) do
    [year, month] =
      socket.assigns.data.labels
      |> List.first()
      |> String.split(".")

    labels = create_months(String.to_integer(year), String.to_integer(month), diff)

    future = get_future_month()
    future_enabled = labels |> List.last() == "#{future.year}.#{future.month}"

    past_enabled = labels |> List.first() != "#{@start_year}.#{@start_month}"

    data =
      socket.assigns.data
      |> Map.put(:labels, labels)
      |> Map.put(:future_enabled, future_enabled)
      |> Map.put(:past_enabled, past_enabled)

    assign(socket, :data, data)
  end

  defp create_data(
         %{
           assigns: %{
             user_id: user_id,
             skill_panel_id: skill_panel_id,
             class: class,
             data: data
           }
         } = socket
       ) do
    data =
      Map.merge(
        data,
        %{
          # role: [10, 20, 50, 60, 75, 100],
          # myself: [nil, 0, 35, 45, 55, 65],
          myself: [nil, 0, 0, 0, 0, 0]
          # other: [10, 10, 25, 35, 45, 70],
          # otherSelected: "2022.12"
        }
      )

    data =
      if data.future_enabled,
        do:
          Map.put(
            data,
            :now,
            SkillScores.get_class_score(user_id, skill_panel_id, class) |> get_now()
          ),
        else: data |> Map.delete(:now)

    assign(socket, data: data)
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
