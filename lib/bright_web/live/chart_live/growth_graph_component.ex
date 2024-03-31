defmodule BrightWeb.ChartLive.GrowthGraphComponent do
  @moduledoc """
  Growth Graph Component
  """

  use BrightWeb, :live_component

  import BrightWeb.ChartComponents
  import BrightWeb.TimelineBarComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper, only: [comparable_user?: 2]

  alias Bright.SkillScores
  alias Bright.HistoricalSkillScores
  alias Bright.UserProfiles
  alias BrightWeb.TimelineHelper
  alias BrightWeb.DisplayUserHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-full">
      <% # 成長グラフ %>
      <div class="flex">
        <div class="w-14 relative">
          <.btn_timeline_shift_past enabled={@timeline.past_enabled} id="myself" myself={@myself} class="absolute -bottom-1 lg:bottom-1" />
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

          <.btn_timeline_shift_future enabled={@timeline.future_enabled} id="myself" myself={@myself} class="absolute -bottom-1 lg:bottom-1" />
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
          display_progress={@display_progress}
        />
        <div class="flex justify-center items-center ml-2"></div>
      </div>

      <% # 比較対象 選択 %>
      <div :if={is_nil @compared_user} class="py-2 lg:py-4">
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
              class="dropdownTarget bg-white rounded-md mt-1 w-full lg:w-[750px] bottom border-brightGray-100 border shadow-md hidden z-10"
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

      <% # 比較対象 表示 %>
      <div :if={compared_other?(@compared_user, @user_id)} id="compared-user-display" class="py-2 lg:py-4">
        <div class="w-14"></div>
        <div class="w-full lg:w-[725px] flex justify-between items-center">
          <div class="text-left flex items-center text-base border border-brightGray-200 px-3 py-1 rounded">
            <img class="inline-block h-10 w-10 rounded-full" src={UserProfiles.icon_url(@compared_user.user_profile.icon_file_path)} />
            <div class="ml-2">
              <p><%= compared_user_name(@compared_user) %></p>
              <p class="text-brightGray-300"><%= @compared_user.user_profile.title %></p>
            </div>
          </div>
        </div>
        <div></div>
      </div>

      <% # タイムライン比較対象用 %>
      <div :if={@compared_user} id="timeline-bar-compared" class="lg:flex lg:items-center">
        <div class="w-14 hidden lg:block" data-size="pc">
          <.btn_timeline_shift_past enabled={@compared_timeline.past_enabled} id="other" myself={@myself} />
        </div>

        <.timeline_bar
          :if={@compared_timeline}
          id="other"
          target={@myself}
          type={if compared_other?(@compared_user, @user_id), do: "other", else: "myself"}
          dates={@compared_timeline.labels}
          selected_date={@compared_timeline.selected_label}
          display_now={@compared_timeline.display_now}
          display_close={true}
        />

        <div class="w-14 hidden lg:flex justify-end" data-size="pc">
          <.btn_timeline_shift_future enabled={@compared_timeline.future_enabled} id="other" myself={@myself} />
        </div>

        <div class="flex justify-between lg:hidden" data-size="sp">
          <% # スマホ版タイムライン移動ボタン %>
          <.btn_timeline_shift_past enabled={@compared_timeline.past_enabled} id="other" myself={@myself} />
          <.btn_timeline_shift_future enabled={@compared_timeline.future_enabled} id="other" myself={@myself} />
        </div>
      </div>
    </div>
    """
  end

  defp btn_timeline_shift_past(%{enabled: true} = assigns) do
    assigns = Map.put_new(assigns, :class, "")

    ~H"""
    <button
      :if={@enabled}
      phx-click="shift_timeline_past"
      phx-value-id={@id}
      phx-target={@myself}
      class={["w-8 h-6 lg:w-11 lg:h-9 bg-brightGray-900 flex justify-center items-center rounded", @class]}
      disabled={false}
    >
      <span class="material-icons text-white !text-xl lg:!text-4xl">arrow_left</span>
    </button>
    """
  end

  defp btn_timeline_shift_past(%{enabled: false} = assigns) do
    assigns = Map.put_new(assigns, :class, "")

    ~H"""
    <button
      :if={!@enabled}
      class={["w-8 h-6 lg:w-11 lg:h-9 bg-brightGray-300 flex justify-center items-center rounded", @class]}
      disabled={true}
    >
      <span class="material-icons text-white !text-xl lg:!text-4xl">arrow_left</span>
    </button>
    """
  end

  defp btn_timeline_shift_future(%{enabled: true} = assigns) do
    assigns = Map.put_new(assigns, :class, "")

    ~H"""
    <button
      :if={@enabled}
      phx-click="shift_timeline_future"
      phx-value-id={@id}
      phx-target={@myself}
      class={["w-8 h-6 lg:w-11 lg:h-9 bg-brightGray-900 flex justify-center items-center rounded", @class]}
      disabled={false}
    >
      <span class="material-icons text-white !text-xl lg:!text-4xl">arrow_right</span>
    </button>
    """
  end

  defp btn_timeline_shift_future(%{enabled: false} = assigns) do
    assigns = Map.put_new(assigns, :class, "")

    ~H"""
    <button
      :if={!@enabled}
      class={["w-8 h-6 lg:w-11 lg:h-9 bg-brightGray-300 flex justify-center items-center rounded", @class]}
      disabled={true}
    >
      <span class="material-icons text-white !text-xl lg:!text-4xl">arrow_right</span>
    </button>
    """
  end

  @impl true
  def mount(socket) do
    timeline = TimelineHelper.get_current()

    {:ok,
     socket
     |> assign(data: %{})
     |> assign(timeline: timeline)
     |> assign(compared_user: nil, compared_timeline: nil, display_progress: false)}
  end

  @impl true
  def update(assigns, socket) do
    assigns = Map.update(assigns, :compared_user, nil, &put_profile/1)

    socket =
      socket
      |> assign(assigns)
      |> create_user_data()
      |> create_compared_user_data()
      |> assign_display_progress()
      |> assign_progress_data()

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "timeline_bar_button_click",
        %{"id" => "myself", "date" => label} = params,
        socket
      ) do
    notify_parent_timeline_clicked(params)

    {:noreply,
     socket
     |> select_data("myself", label)
     |> assign_display_progress()}
  end

  def handle_event(
        "timeline_bar_button_click",
        %{"id" => "other", "date" => label} = params,
        socket
      ) do
    notify_parent_timeline_clicked(params)

    {:noreply,
     socket
     |> select_data("other", label)
     |> assign_display_progress()}
  end

  def handle_event("shift_timeline_past", %{"id" => "myself"}, socket) do
    timeline = TimelineHelper.shift_for_past(socket.assigns.timeline)

    {:noreply,
     socket
     |> assign(timeline: timeline)
     |> create_user_data()
     |> assign_display_progress()}
  end

  def handle_event("shift_timeline_past", %{"id" => "other"}, socket) do
    compared_timeline = TimelineHelper.shift_for_past(socket.assigns.compared_timeline)

    {:noreply,
     socket
     |> assign(compared_timeline: compared_timeline)
     |> create_compared_user_data()
     |> assign_display_progress()}
  end

  def handle_event("shift_timeline_future", %{"id" => "myself"}, socket) do
    timeline = TimelineHelper.shift_for_future(socket.assigns.timeline)

    {:noreply,
     socket
     |> assign(timeline: timeline)
     |> create_user_data()
     |> assign_display_progress()}
  end

  def handle_event("shift_timeline_future", %{"id" => "other"}, socket) do
    compared_timeline = TimelineHelper.shift_for_future(socket.assigns.compared_timeline)

    {:noreply,
     socket
     |> assign(compared_timeline: compared_timeline)
     |> create_compared_user_data()
     |> assign_display_progress()}
  end

  def handle_event("compare_myself", _params, socket) do
    %{current_user: user, timeline: timeline} = socket.assigns

    user = Map.put(user, :anonymous, false)
    compared_timeline = timeline
    notify_parent_compared_user_added(user, compared_timeline)

    {:noreply,
     socket
     |> assign(compared_timeline: compared_timeline)
     |> assign(compared_user: user)
     |> create_compared_user_data()
     |> assign_display_progress()}
  end

  def handle_event("click_on_related_user_card_compare", params, socket) do
    %{
      timeline: timeline,
      current_user: current_user,
      compared_user: compared_user
    } = socket.assigns

    compared_timeline = timeline

    {user, anonymous} =
      DisplayUserHelper.get_user_from_name_or_name_encrypted(
        params["name"],
        params["encrypt_user_name"]
      )

    user = user |> Map.put(:anonymous, anonymous) |> put_profile()

    comparable_user?(user, %{
      current_user: current_user,
      compared_users: List.wrap(compared_user),
      display_user: nil
    })
    |> if do
      notify_parent_compared_user_added(user, compared_timeline)

      {:noreply,
       socket
       |> assign(compared_timeline: compared_timeline)
       |> assign(compared_user: user)
       |> create_compared_user_data()
       |> assign_display_progress()}
    else
      # 変更なしかあるいは権限なし
      {:noreply, socket}
    end
  end

  def handle_event("timeline_bar_close_button_click", _params, socket) do
    notify_parent_compared_user_deleted()

    {:noreply,
     socket
     |> assign(compared_timeline: nil)
     |> assign(compared_user: nil)
     |> create_compared_user_data()
     |> assign_display_progress()}
  end

  defp create_user_data(socket) do
    %{
      user_id: user_id,
      skill_panel_id: skill_panel_id,
      skill_class: skill_class,
      timeline: timeline,
      data: data
    } = socket.assigns

    past_values = get_past_score_values(timeline, user_id, skill_panel_id, skill_class.class)

    data =
      Map.merge(data, %{
        myself: past_values,
        myselfSelected: timeline.selected_label,
        labels: timeline.labels,
        # タイムライン上で未来方向に操作不可であれば、成長グラフ上未来は表示状態
        futureDisplay: !timeline.future_enabled
      })

    now_value =
      create_user_now_value(user_id, skill_panel_id, skill_class.class, !timeline.future_enabled)

    data = Map.put(data, :myselfNow, now_value)

    assign(socket, data: data)
  end

  defp create_compared_user_data(%{assigns: %{compared_user: nil}} = socket) do
    update(socket, :data, fn data ->
      Map.merge(data, %{
        other: [],
        otherSelected: nil,
        comparedOther: nil,
        otherLabels: [],
        otherFutureDisplay: nil,
        otherNow: nil
      })
    end)
  end

  defp create_compared_user_data(socket) do
    %{
      compared_user: compared_user,
      user_id: user_id,
      skill_panel_id: skill_panel_id,
      skill_class: skill_class,
      compared_timeline: compared_timeline,
      timeline: timeline
    } = socket.assigns

    compared_timeline = compared_timeline || timeline

    past_values =
      get_past_score_values(
        compared_timeline,
        compared_user.id,
        skill_panel_id,
        skill_class.class
      )

    now_value =
      create_user_now_value(
        compared_user.id,
        skill_panel_id,
        skill_class.class,
        !compared_timeline.future_enabled
      )

    socket
    |> assign(:compared_timeline, compared_timeline)
    |> update(:data, fn data ->
      Map.merge(data, %{
        other: past_values,
        otherSelected: compared_timeline.selected_label,
        comparedOther: compared_other?(compared_user, user_id),
        otherLabels: compared_timeline.labels,
        # タイムライン上で未来方向に操作不可であれば、成長グラフ上未来は表示状態
        otherFutureDisplay: !compared_timeline.future_enabled,
        otherNow: now_value
      })
    end)
  end

  defp create_user_now_value(user_id, skill_panel_id, class, required)

  defp create_user_now_value(user_id, skill_panel_id, class, true) do
    (SkillScores.get_class_score(user_id, skill_panel_id, class) || %{})
    |> Map.get(:percentage, 0)
  end

  defp create_user_now_value(_user_id, _skill_panel_id, _class, false), do: nil

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

  defp assign_display_progress(socket) do
    %{compared_user: compared_user, timeline: timeline} = socket.assigns
    display_progress = !compared_user && timeline.selected_label == "now"

    socket
    |> assign(:display_progress, display_progress)
    |> update(:data, &Map.put(&1, :displayProgress, display_progress))
  end

  defp assign_progress_data(%{assigns: %{display_progress: false}} = socket) do
    update(socket, :data, &Map.put(&1, :progress, []))
  end

  defp assign_progress_data(socket) do
    %{
      user_id: user_id,
      skill_class: skill_class,
      timeline: timeline
    } = socket.assigns

    # 変遷データ取得
    progress =
      SkillScores.list_user_skill_class_score_progress(
        %{id: user_id},
        skill_class,
        TimelineHelper.get_prev_date_from_now(timeline),
        Date.utc_today()
      )

    # 成長グラフ上で「現在」と直前点が近すぎるためnilデータを挿入
    progress = progress ++ [nil, nil, nil, nil, nil]

    update(socket, :data, &Map.put(&1, :progress, progress))
  end

  defp compared_other?(compared_user, user_id) do
    compared_user && !(compared_user.id == user_id)
  end

  defp compared_user_name(%{anonymous: true}), do: "非表示"

  defp compared_user_name(%{anonymous: false, name: name}), do: name

  defp notify_parent_timeline_clicked(params) do
    Process.send(self(), %{event_name: "timeline_bar_button_click", params: params}, [])
  end

  defp notify_parent_compared_user_added(user, timeline) do
    Process.send(
      self(),
      %{
        event_name: "compared_user_added",
        params: %{
          "compared_user" => user,
          "select_label" => timeline.selected_label
        }
      },
      []
    )
  end

  defp notify_parent_compared_user_deleted do
    Process.send(self(), %{event_name: "compared_user_deleted", params: %{}}, [])
  end
end
