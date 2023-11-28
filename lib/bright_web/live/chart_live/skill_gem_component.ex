defmodule BrightWeb.ChartLive.SkillGemComponent do
  @moduledoc """
  Skill Gem Component
  """
  use BrightWeb, :live_component
  import BrightWeb.ChartComponents
  alias Bright.SkillScores
  alias Bright.HistoricalSkillScores
  alias BrightWeb.PathHelper
  alias BrightWeb.TimelineHelper

  # SkillGemComponentの引数
  # id: 一意になるid
  # display_user: 表示するユーザー
  # skill_panel: 表示するキルパネル
  # class: 表示するクラス(1〜3)
  # select_label 表示する時間　"now" or 例 "2023.10"
  # me: 自分自身の場合はtrue
  # anonymous: 匿名はfalse
  # size: base: 成長パネル md:チーム分析 sm:マイページ
  # display_link:　falseでスキルジェムのリンクを非表示にする

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto w-full -mt-24 lg:mt-0 lg:w-[450px]">
      <%= if length(@skill_gem_labels) < 3 do %>
        <div class="bg-white w-[450px] h-[360px] flex items-center justify-center">
          <p class="text-start font-bold">データが破損しています</p>
        </div>
      <% else %>
        <.skill_gem
          data={@skill_gem_data}
          id={@id}
          labels={@skill_gem_labels}
          links={@skill_gem_links}
          display_link={@display_link}
          size={@size}
          color_theme={@color_theme}
        />
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
      socket
      |> assign(:skill_gem_data, nil)
      |> assign(:color_theme, "myself")}
  end

  @impl true
  def update(assigns, socket) do
    skill_gem_update_required = skill_gem_update_required?(socket.assigns, assigns)

    skill_gem_compared_user_update_required =
      skill_gem_compared_user_update_required?(socket.assigns, assigns)

    {:ok,
     socket
     |> assign(assigns)
     |> maybe_update_skill_gem(skill_gem_update_required)
     |> maybe_update_skill_gem_data_compared_user(skill_gem_compared_user_update_required)}
  end

  defp maybe_update_skill_gem(socket, true) do
    %{
      display_user: display_user,
      skill_panel: skill_panel,
      class: class,
      me: me,
      anonymous: anonymous
    } = socket.assigns

    select_label = socket.assigns[:select_label] || "now"
    display_link = socket.assigns[:display_link] || "true"
    size = socket.assigns[:size] || "base"
    skill_gem = get_skill_gem(display_user.id, skill_panel.id, class, select_label)

    socket
    |> update(:skill_gem_data, fn
      [_, other] when is_list(other) -> [get_skill_gem_data(skill_gem), other]
      _ -> [get_skill_gem_data(skill_gem)]
    end)
    |> assign(:skill_gem_labels, get_skill_gem_labels(skill_gem))
    |> assign(:skill_gem_trace_ids, get_skill_gem_trace_ids(skill_gem))
    |> assign(
      :skill_gem_links,
      get_skill_gem_links(
        skill_gem,
        skill_panel,
        class,
        select_label,
        display_user,
        me,
        anonymous
      )
    )
    |> assign(:display_link, display_link)
    |> assign(:size, size)
  end

  defp maybe_update_skill_gem(socket, _update_required), do: socket

  defp maybe_update_skill_gem_data_compared_user(
         %{assigns: %{compared_user: nil}} = socket,
         _update_required
       ) do
    # 比較対象がない（あるいは削除）ケース
    socket
    |> update(:skill_gem_data, fn
      [myself, _] when is_list(myself) -> [myself]
      data -> data
    end)
    |> assign(:color_theme, "myself")
  end

  defp maybe_update_skill_gem_data_compared_user(socket, true) do
    # 比較対象がある（あるいは新規）ケース
    %{
      compared_user: compared_user,
      display_user: display_user,
      select_label_compared_user: select_label,
      skill_panel: skill_panel,
      class: class,
      skill_gem_trace_ids: skill_gem_trace_ids
    } = socket.assigns

    # 自分自身と比較と、他者との比較で色などが異なるため判定準備
    compared_other? = (compared_user.id != display_user.id)

    # データ取得後に自身ジェムとスキルユニットが一致するデータを取得している。
    # 参照している過去時点がずれている場合に一致しない。
    skill_gem = get_skill_gem(compared_user.id, skill_panel.id, class, select_label)
    value_by_trace_id = Map.new(skill_gem, &{&1.trace_id, &1.percentage})
    skill_gem_data = Enum.map(skill_gem_trace_ids, &Map.get(value_by_trace_id, &1, 0))
    color_theme = if(compared_other?, do: "other", else: "myself")

    socket
    |> update(:skill_gem_data, fn
      [myself, _] when is_list(myself) -> [myself, skill_gem_data]
      [myself] -> [myself, skill_gem_data]
    end)
    |> update(:skill_gem_data, fn skill_gem_data ->
      compared_other?
      |> if do
        skill_gem_data
      else
        # 自分自身と比較時の補完
        # - スキルジェム上の色合いの関係上、常に大きい方を先に置く。
        # - スキルジェム上の色合いの関係上、同値であれば１つだけ表示する
        skill_gem_data
        |> Enum.sort_by(& Enum.sum/1, :desc)
        |> Enum.uniq()
      end
    end)
    |> assign(:color_theme, color_theme)
  end

  defp maybe_update_skill_gem_data_compared_user(socket, _update_required), do: socket

  defp get_skill_gem(user_id, skill_panel_id, class, select_label) when select_label == "now",
    do: SkillScores.get_skill_gem(user_id, skill_panel_id, class)

  defp get_skill_gem(user_id, skill_panel_id, class, select_label) do
    locked_date = TimelineHelper.label_to_date(select_label)

    HistoricalSkillScores.get_historical_skill_gem(
      user_id,
      skill_panel_id,
      class,
      TimelineHelper.get_shift_date_from_date(locked_date, -1)
    )
  end

  defp get_skill_gem_data(skill_gem), do: Enum.map(skill_gem, fn x -> x.percentage end)

  defp get_skill_gem_labels(skill_gem), do: Enum.map(skill_gem, fn x -> x.name end)

  defp get_skill_gem_trace_ids(skill_gem), do: Enum.map(skill_gem, fn x -> x.trace_id end)

  defp get_skill_gem_links(
         skill_gem,
         skill_panel,
         class,
         select_label,
         display_user,
         me,
         anonymous
       ) do
    base_path = PathHelper.skill_panel_path("panels", skill_panel, display_user, me, anonymous)
    class = if class, do: "class=#{class}", else: ""
    timeline = if select_label != "now", do: "timeline=#{select_label}", else: ""
    query = Enum.join([class, timeline], "&")
    path = base_path <> "?#{query}"

    skill_gem
    |> Enum.with_index(1)
    |> Enum.map(fn {_x, index} -> "#{path}#unit-#{index}" end)
  end

  defp skill_gem_update_required?(prev_assigns, new_assigns) do
    first_time?(prev_assigns) ||
      data_changed?(prev_assigns, new_assigns, :select_label) ||
      data_changed?(prev_assigns, new_assigns, :class)
  end

  defp skill_gem_compared_user_update_required?(prev_assigns, new_assigns) do
    # 比較対象変更
    data_changed?(prev_assigns, new_assigns, :compared_user) ||
      # 比較対象ラベル変更
      data_changed?(prev_assigns, new_assigns, :select_label_compared_user) ||
      # 比較対象ありの状態でのクラス変更
      (Map.get(new_assigns, :compared_user) && data_changed?(prev_assigns, new_assigns, :class)) ||
      # 自分自身との比較時
      ((Map.get(new_assigns, :compared_user) || %{id: nil}).id == new_assigns.display_user.id)
  end

  defp first_time?(prev_assigns) do
    is_nil(Map.get(prev_assigns, :display_user))
  end

  defp data_changed?(prev_assigns, new_assigns, attr_name) do
    prev = Map.get(prev_assigns, attr_name)
    new = Map.get(new_assigns, attr_name)
    prev != new
  end
end
