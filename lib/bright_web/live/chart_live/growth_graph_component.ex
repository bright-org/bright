defmodule BrightWeb.ChartLive.GrowthGraphComponent do
  @moduledoc """
  Growth Graph Component
  """

  use BrightWeb, :live_component

  import BrightWeb.ChartComponents
  import BrightWeb.TimelineBarComponents

  alias Bright.SkillScores
  alias Bright.HistoricalSkillScores
  alias Bright.UserProfiles
  alias BrightWeb.TimelineHelper
  alias BrightWeb.DisplayUserHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-full lg:w-[880px]">

      <% # ロールモデル解除 %>
      <div class="ml-auto mr-28 mt-6 mb-1">
        <%# TODO 他者選択できるまで非表示 %>
        <button :if={false}
          type="button"
          class="text-brightGray-600 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
        >
          ロールモデルを解除
        </button>
      </div>

      <% # 成長グラフ %>
      <div class="flex">
        <div class="w-14 relative">
          <button
            :if={@timeline.past_enabled}
            phx-click="shift_timeline_past"
            phx-value-id="myself"
            phx-target={@myself}
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
            phx-click="shift_timeline_future"
            phx-value-id="myself"
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

      <% # タイムライン自身 %>
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

      <% # 比較対象 選択 PCのみ %>
      <div :if={is_nil @compared_user} class="hidden lg:flex py-4">
        <div class="w-7 lg:w-14"> </div>
        <div class="flex gap-x-4">
          <button
            class="text-brightGray-600 bg-white px-2 py-2 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
            type="button"
            phx-click="compare_myself"
            phx-target={@myself}
          >
            <span class="min-w-[6em]">自分と比較</span>
          </button>
          <div
            id="compare-indivividual-dropdown"
            class="mt-4 lg:mt-0 hidden lg:block"
            phx-hook="Dropdown"
            data-dropdown-offset-skidding="307"
            data-dropdown-placement="bottom"
          >
            <button
              class="dropdownTrigger border border-brightGray-200 rounded-md py-1.5 pl-3 flex items-center"
              type="button"
            >
              <span class="min-w-[6em]">他者と比較</span>
              <span
                class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-7px] before:bg-brightGray-200 before:w-[1px] before:h-[38px]"
                >add</span>
            </button>
            <div
              class="dropdownTarget bg-white rounded-md mt-1 w-[750px] bottom border-brightGray-100 border shadow-md hidden z-10"
            >
              <.live_component
                id="related-user-card-compare"
                module={BrightWeb.CardLive.RelatedUserCardComponent}
                current_user={@current_user}
                display_menu={false}
                purpose="compare"
                card_row_click_target={@myself}
              />
            </div>
          </div>
        </div>
        <div class="flex justify-center items-center ml-2"></div>
      </div>

      <% # 比較対象 表示 PCのみ %>
      <div :if={compared_user_display?(@compared_user, @user_id)} id="compared-user-display" class="hidden lg:flex py-4">
        <div class="w-14"></div>
        <div class="w-[725px] flex justify-between items-center">
          <div class="text-left flex items-center text-base border border-brightGray-200 px-3 py-1 rounded">
            <img class="inline-block h-10 w-10 rounded-full" src={UserProfiles.icon_url(@compared_user.user_profile.icon_file_path)} />
            <div class="ml-2">
              <p><%= compared_user_name(@compared_user) %></p>
              <p class="text-brightGray-300"><%= @compared_user.user_profile.title %></p>
            </div>
          </div>
          <%# TODO ロールモデル対応できるまで非表示 %>
          <button :if={false}
            type="button"
            class="text-brightGray-600 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
          >
            ロールモデルに固定
          </button>
        </div>
        <div></div>
      </div>

      <% # タイムライン比較対象用 PCのみ %>
      <div :if={@compared_user} id="timeline-bar-compared" class="flex">
        <div class="w-14 flex justify-start items-center">
          <button
            :if={@compared_timeline.past_enabled}
            phx-click="shift_timeline_past"
            phx-value-id="other"
            phx-target={@myself}
            class="w-8 h-6 lg:w-11 lg:h-9 bg-brightGray-900 flex justify-center items-center rounded"
            disabled={false}
          >
            <span class="material-icons text-white !text-xl lg:!text-4xl">arrow_left</span>
          </button>
          <button
            :if={!@compared_timeline.past_enabled}
            phx-target={@myself}
            class="w-8 h-6 lg:w-11 lg:h-9 bg-brightGray-300 flex justify-center items-center rounded"
            disabled={true}
          >
            <span class="material-icons text-white !text-4xl">arrow_left</span>
          </button>
        </div>

        <.timeline_bar
          :if={@compared_timeline}
          id="other"
          target={@myself}
          type="other"
          dates={@compared_timeline.labels}
          selected_date={@compared_timeline.selected_label}
          display_now={false}
        />

        <div class="w-14 flex justify-end items-center">
          <button
            :if={@compared_timeline.future_enabled}
            phx-click="shift_timeline_future"
            phx-value-id="other"
            phx-target={@myself}
            class="w-8 h-6 lg:w-11 lg:h-9 bg-brightGray-900 flex justify-center items-center rounded"
            disabled={false}
          >
            <span class="material-icons text-white !text-xl lg:!text-4xl">arrow_right</span>
          </button>
          <button
            :if={!@compared_timeline.future_enabled}
            class="w-8 h-6 lg:w-11 lg:h-9 bg-brightGray-300 flex justify-center items-center rounded"
            disabled={true}
          >
            <span class="material-icons text-white !text-xl lg:!text-4xl">arrow_right</span>
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(data: %{})
     |> assign(compared_user: nil)}
  end

  @impl true
  def update(assigns, socket) do
    timeline = TimelineHelper.get_current()

    socket =
      socket
      |> assign(assigns)
      |> assign(timeline: timeline)
      |> create_user_data()

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "timeline_bar_button_click",
        %{"id" => "myself", "date" => label} = params,
        socket
      ) do
    Process.send(self(), %{event_name: "timeline_bar_button_click", params: params}, [])
    {:noreply, select_data(socket, "myself", label)}
  end

  def handle_event("timeline_bar_button_click", %{"id" => "other", "date" => label}, socket) do
    {:noreply, select_data(socket, "other", label)}
  end

  def handle_event("shift_timeline_past", %{"id" => "myself"}, socket) do
    timeline = TimelineHelper.shift_for_past(socket.assigns.timeline)

    {:noreply,
     socket
     |> assign(timeline: timeline)
     |> create_user_data()}
  end

  def handle_event("shift_timeline_past", %{"id" => "other"}, socket) do
    compared_timeline = TimelineHelper.shift_for_past(socket.assigns.compared_timeline)

    {:noreply,
     socket
     |> assign(compared_timeline: compared_timeline)
     |> create_compared_user_data()}
  end

  def handle_event("shift_timeline_future", %{"id" => "myself"}, socket) do
    timeline = TimelineHelper.shift_for_future(socket.assigns.timeline)

    {:noreply,
     socket
     |> assign(timeline: timeline)
     |> create_user_data()}
  end

  def handle_event("shift_timeline_future", %{"id" => "other"}, socket) do
    compared_timeline = TimelineHelper.shift_for_future(socket.assigns.compared_timeline)

    {:noreply,
     socket
     |> assign(compared_timeline: compared_timeline)
     |> create_compared_user_data()}
  end

  def handle_event("compare_myself", _params, socket) do
    compared_timeline = TimelineHelper.select_past_if_label_is_now(socket.assigns.timeline)

    {:noreply,
     socket
     |> assign(compared_timeline: compared_timeline)
     |> assign(compared_user: socket.assigns.current_user)
     |> create_compared_user_data()}
  end

  def handle_event("click_on_related_user_card_compare", params, socket) do
    compared_timeline = TimelineHelper.select_past_if_label_is_now(socket.assigns.timeline)

    # TODO: 本当に参照可能かのチェックをいれること
    {user, anonymous} =
      DisplayUserHelper.get_user_from_name_or_name_encrypted(
        params["name"],
        params["encrypt_user_name"]
      )

    user =
      user
      |> Map.put(:anonymous, anonymous)
      |> put_profile()

    {:noreply,
     socket
     |> assign(compared_timeline: compared_timeline)
     |> assign(compared_user: user)
     |> create_compared_user_data()}
  end

  def handle_event("timeline_bar_close_button_click", _params, socket) do
    {:noreply,
     socket
     |> assign(compared_timeline: nil)
     |> assign(compared_user: nil)}
  end

  defp create_user_data(socket) do
    %{
      user_id: user_id,
      skill_panel_id: skill_panel_id,
      class: class,
      timeline: timeline,
      data: data
    } = socket.assigns

    past_values = get_past_score_values(timeline, user_id, skill_panel_id, class)

    data =
      Map.merge(data, %{
        myself: past_values,
        myselfSelected: timeline.selected_label,
        labels: timeline.labels,
        # TODO: ここ`!`は意味が反転しているので未来対応時に要確認。timelineのfuture_enabled（未来選択可能)とグラフデータ上のfuture_enabled(未来が表示されている?)というようにそれぞれで意味が違うのかもしれない。
        futureEnabled: !timeline.future_enabled
      })

    # 「現在」表示が存在するならばいれる。そうでないならばキー自体を除去
    # TODO: ここもfuture_enabledの意味が反転している?ので要確認
    now_value =
      if data.futureEnabled do
        (SkillScores.get_class_score(user_id, skill_panel_id, class) || %{})
        |> Map.get(:percentage, 0)
      end

    data = if now_value, do: Map.put(data, :now, now_value), else: Map.delete(data, :now)

    assign(socket, data: data)
  end

  defp create_compared_user_data(socket) do
    %{
      compared_user: compared_user,
      skill_panel_id: skill_panel_id,
      class: class,
      compared_timeline: compared_timeline
    } = socket.assigns

    past_values =
      get_past_score_values(compared_timeline, compared_user.id, skill_panel_id, class)

    update(socket, :data, fn data ->
      Map.merge(data, %{
        other: past_values,
        otherSelected: compared_timeline.selected_label,
        otherLabels: compared_timeline.labels,
        # TODO: ここ`!`は意味が反転しているので未来対応時に要確認。timelineのfuture_enabled（未来選択可能)とグラフデータ上のfuture_enabled(未来が表示されている?)というようにそれぞれで意味が違うのかもしれない。
        otherFutureEnabled: !compared_timeline.future_enabled
      })
    end)
  end

  defp get_past_score_values(timeline, user_id, skill_panel_id, class) do
    # タイムラインに表示されている範囲の過去履歴を取得する
    # to_date_index: タイムラインに未来が表示されているかどうかを考慮し決定
    from_date = TimelineHelper.get_date_at(timeline, 0)
    future_display_on_timeline? = if(timeline.future_enabled, do: false, else: true)
    to_date_index = if(future_display_on_timeline?, do: -2, else: -1)
    to_date = TimelineHelper.get_date_at(timeline, to_date_index)

    # タイムライン上の点より、1つ過去から線を引くため1つ前にしている
    invisible_past_date = TimelineHelper.get_shift_date_from_date(from_date, -1)

    date_percentages =
      HistoricalSkillScores.list_historical_skill_class_score_percentages(
        skill_panel_id,
        class,
        user_id,
        # 取得においてスキル構造系のデータから引くため1つ前のlocked_dateを指定している
        TimelineHelper.get_shift_date_from_date(invisible_past_date, -1),
        TimelineHelper.get_shift_date_from_date(to_date, -1)
      )
      |> Map.new()

    # past_values: lablesの日付が小さい順にそのときの取得率
    past_values =
      timeline.labels
      |> Enum.map(&TimelineHelper.label_to_date/1)
      |> Enum.sort({:asc, Date})
      |> Enum.map(&(Map.get(date_percentages, &1) || 0))

    invisible_past_value = Map.get(date_percentages, invisible_past_date) || 0

    [invisible_past_value | past_values]
  end

  defp select_data(socket, "myself", label) do
    timeline = TimelineHelper.select_label(socket.assigns.timeline, label)

    socket
    |> assign(timeline: timeline)
    |> update(:data, &Map.put(&1, :myselfSelected, label))
  end

  defp select_data(socket, "other", label) do
    compared_timeline = TimelineHelper.select_label(socket.assigns.compared_timeline, label)

    socket
    |> assign(compared_timeline: compared_timeline)
    |> update(:data, &Map.put(&1, :otherSelected, label))
  end

  defp put_profile(%{anonymous: true} = user) do
    Map.put(user, :user_profile, UserProfiles.get_anonymous_user_profile())
  end

  defp put_profile(user) do
    Bright.Repo.preload(user, :user_profile)
  end

  defp compared_user_display?(compared_user, user_id) do
    compared_user && !(compared_user.id == user_id)
  end

  defp compared_user_name(%{anonymous: true}), do: "非表示"

  defp compared_user_name(%{anonymous: false, name: name}), do: name
end
