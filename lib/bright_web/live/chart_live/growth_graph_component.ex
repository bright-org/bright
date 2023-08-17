defmodule BrightWeb.ChartLive.GrowthGraphComponent do
  @moduledoc """
  Growth Graph Component
  """

  use BrightWeb, :live_component
  import BrightWeb.ChartComponents
  import BrightWeb.TimelineBarComponents
  alias Bright.SkillScores
  alias BrightWeb.SkillPanelLive.TimelineHelper

  @start_year 2021
  @start_month 10
  @monthly_interval 3

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
              phx-click={JS.push("month_add_click", value: %{id: "myself" })}
              phx-target={@myself}
              class="w-11 h-9 bg-brightGray-900 flex justify-center items-center rounded bottom-1 absolute"
              disabled={false}
            >
              <span class="material-icons text-white !text-4xl">arrow_right</span>
            </button>
            <button
              :if={!@data.future_enabled}
              class="w-11 h-9 bg-brightGray-300 flex justify-center items-center rounded bottom-1 absolute"
              disabled={true}
            >
              <span class="material-icons text-white !text-4xl">arrow_right</span>
            </button>
          </div>
        </div>
        <div class="flex">
          <div class="w-14"></div>
          <.timeline_bar
            id="myself"
            target={@myself}
            type="myself"
            dates={@data.labels}
            selected_date={@data.myselfSelected}
            display_now={@data.future_enabled}
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
            selected_date="2022.12"
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

    socket =
      socket
      |> assign(:data, %{
        myselfSelected: "now",
        labels: timeline.labels,
        future_enabled: timeline.future_enabled,
        past_enabled: timeline.past_enabled
      })
      |> create_data()

    {:ok, socket}
    |> IO.inspect()
  end


  @impl true
  def handle_event("timeline_bar_button_click", params, socket) do
    Process.send(self(), %{event_name: "timeline_bar_button_click", params: params}, [])
    timeline =
      socket.assigns.timeline
      |> TimelineHelper.select_label(params["date"])

    socket = socket |> assign(timeline: timeline) |> select_data()
    {:noreply, socket}
  end

  def handle_event("month_subtraction_click", _params, socket) do
    timeline =
      socket.assigns.timeline
      |> TimelineHelper.shift_for_past()


    socket = socket
    |> assign(timeline: timeline)

    {:noreply, create_labels(socket) |> create_data()}
  end

  def handle_event("month_add_click", _params, socket) do
    timeline =
      socket.assigns.timeline
      |> TimelineHelper.shift_for_future()

    socket = socket
    |> assign(timeline: timeline)


    {:noreply, create_labels(socket) |> create_data()}
  end

  defp create_labels(socket) do
    data =
      socket.assigns.data
      |> Map.put(:labels, socket.assigns.timeline.labels)
      |> Map.put(:future_enabled, socket.assigns.timeline.future_enabled)
      |> Map.put(:past_enabled, socket.assigns.timeline.past_enabled)

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
    from_date =
      data.labels
      |> List.first()
      |> label_to_date()
      |> Timex.shift(months: -@monthly_interval)

    to_date =
      data.labels
      |> List.last()
      |> label_to_date()

    myself_init_data =
      [date_to_label(from_date) | data.labels]
      |> Enum.map(fn x -> {:"#{label_to_key_date(x)}", 0} end)

    myself =
      SkillScores.get_historical_skill_class_scores(
        skill_panel_id,
        class,
        user_id,
        from_date,
        to_date
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
