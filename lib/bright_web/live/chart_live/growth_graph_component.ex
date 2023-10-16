defmodule BrightWeb.ChartLive.GrowthGraphComponent do
  @moduledoc """
  Growth Graph Component
  """

  use BrightWeb, :live_component
  import BrightWeb.ChartComponents
  import BrightWeb.TimelineBarComponents
  alias Bright.SkillScores
  alias Bright.HistoricalSkillScores
  alias BrightWeb.TimelineHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-full lg:w-[880px]">
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
            :if={@timeline.past_enabled}
            phx-target={@myself}
            phx-click={JS.push("shift_timeline_past", value: %{id: "myself" })}
            class="w-8 h-6 bg-brightGray-900 flex justify-center items-center rounded absolute -bottom-1 lg:bottom-1 lg:w-11 lg:h-9"
            disabled={false}
          >
            <span class="material-icons text-white !text-xl lg:!text-4xl">arrow_left</span>
          </button>
          <button
            :if={!@timeline.past_enabled}
            phx-target={@myself}
            class="w-8 h-6 bg-brightGray-300 flex justify-center items-center rounded absolute -bottom-1 lg:bottom-1 lg:w-11 lg:h-9"
            disabled={true}
          >
            <span class="material-icons text-white !text-4xl">arrow_left</span>
          </button>
        </div>
        <div class="hidden lg:block">
          <.growth_graph data={@data} id="growth-graph"/>
        </div>
        <div class="lg:hidden">
          <.growth_graph data={@data} id="growth-graph-sp" size="sp" />
        </div>
        <div class="ml-1 flex flex-col relative text-xs text-brightGray-500 text-bold w-20 lg:ml-5 lg:text-xl lg:w-20">
          <p class="py-4 lg:py-5">ベテラン</p>
          <p class="py-3 lg:py-20">平均</p>
          <p class="py-2 lg:py-6">見習い</p>
          <button
            :if={@timeline.future_enabled}
            phx-click={JS.push("shift_timeline_future", value: %{id: "myself" })}
            phx-target={@myself}
            class="w-8 h-6 bg-brightGray-900 flex justify-center items-center rounded absolute -bottom-1 lg:bottom-1 lg:w-11 lg:h-9"
            disabled={false}
          >
            <span class="material-icons text-white !text-xl lg:!text-4xl">arrow_right</span>
          </button>
          <button
            :if={!@timeline.future_enabled}
            class="w-8 h-6 bg-brightGray-300 flex justify-center items-center rounded absolute -bottom-1 lg:bottom-1 lg:w-11 lg:h-9"
            disabled={true}
          >
            <span class="material-icons text-white !text-xl lg:!text-4xl">arrow_right</span>
          </button>
        </div>
      </div>
      <div class="flex">
        <div class="w-7 lg:w-14"></div>
        <.timeline_bar
          id="myself"
          target={@myself}
          type="myself"
          dates={@timeline.labels}
          selected_date={@timeline.selected_label}
          display_now={@timeline.display_now}
        />
        <div class="flex justify-center items-center ml-2"></div>
      </div>
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
      <div :if={false} class="flex">
        <div class="w-14"></div>
        <.timeline_bar
          id="other"
          target={@myself}
          type="other"
          dates={["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"]}
          selected_date="2023.12"
        />
        <div class="flex justify-center items-center ml-2"></div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    timeline = TimelineHelper.get_current()

    socket =
      socket
      |> assign(assigns)
      |> assign(timeline: timeline)
      |> create_data()

    {:ok, socket}
  end

  @impl true
  def handle_event("timeline_bar_button_click", %{"date" => date} = params, socket) do
    Process.send(self(), %{event_name: "timeline_bar_button_click", params: params}, [])

    timeline =
      socket.assigns.timeline
      |> TimelineHelper.select_label(date)

    socket =
      socket
      |> assign(timeline: timeline)
      |> select_data()

    {:noreply, socket}
  end

  def handle_event("shift_timeline_past", _params, socket) do
    timeline =
      socket.assigns.timeline
      |> TimelineHelper.shift_for_past()

    socket =
      socket
      |> assign(timeline: timeline)
      |> create_data()

    {:noreply, socket}
  end

  def handle_event("shift_timeline_future", _params, socket) do
    timeline =
      socket.assigns.timeline
      |> TimelineHelper.shift_for_future()

    socket =
      socket
      |> assign(timeline: timeline)
      |> create_data()

    {:noreply, socket}
  end

  defp create_data(
         %{
           assigns: %{
             user_id: user_id,
             skill_panel_id: skill_panel_id,
             class: class,
             timeline: timeline
           }
         } = socket
       ) do
    data = %{
      myselfSelected: timeline.selected_label,
      labels: timeline.labels,
      future_enabled: !timeline.future_enabled,
      past_enabled: timeline.past_enabled
    }

    from_date =
      data.labels
      |> List.first()
      |> label_to_date()
      |> Timex.shift(months: -TimelineHelper.get_monthly_interval())

    # 未来データは別のテーブから取得するため、過去の範囲の日付にする
    to_date_label_index = if data.future_enabled, do: -2, else: -1

    to_date =
      data.labels
      |> Enum.at(to_date_label_index)
      |> label_to_date()

    myself_init_data =
      [date_to_label(from_date) | data.labels]
      |> Enum.map(fn x -> {:"#{label_to_key_date(x)}", 0} end)

    myself =
      HistoricalSkillScores.list_historical_skill_class_score_percentages(
        skill_panel_id,
        class,
        user_id,
        TimelineHelper.get_shift_date_from_date(from_date, -1),
        TimelineHelper.get_shift_date_from_date(to_date, -1)
      )
      |> Enum.reduce(myself_init_data, fn {key, val}, acc ->
        Keyword.put(acc, label_to_key_date(date_to_label(key)) |> String.to_atom(), val)
      end)
      |> Keyword.take(Keyword.keys(myself_init_data))
      |> Enum.sort()
      |> Keyword.values()

    data =
      Map.merge(
        data,
        %{
          # role: [10, 20, 50, 60, 75, 100],
          # myself: [nil, 0, 35, 45, 55, 65],
          myself: myself
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

  defp label_to_date(label) do
    [year, month] = String.split(label, ".") |> Enum.map(&String.to_integer/1)
    {year, month, 1} |> Date.from_erl!()
  end

  defp label_to_key_date(label) do
    [year, month] = String.split(label, ".")
    month = String.pad_leading(month, 2, "0")
    "#{year}.#{month}"
  end

  defp date_to_label(data), do: "#{data.year}.#{data.month}"

  defp select_data(socket) do
    data =
      socket.assigns.data
      |> Map.put(:myselfSelected, socket.assigns.timeline.selected_label)

    assign(socket, :data, data)
  end

  defp get_now(%{percentage: now}), do: now
  defp get_now(nil), do: 0
end
