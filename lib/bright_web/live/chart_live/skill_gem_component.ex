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
  # size: base: 成長グラフ md:チーム分析 sm:マイページ
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
        />
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :skill_gem_data, nil)}
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
    update(socket, :skill_gem_data, fn
      [myself, _] when is_list(myself) -> [myself]
      data -> data
    end)
  end

  defp maybe_update_skill_gem_data_compared_user(socket, true) do
    # 比較対象がある（あるいは新規）ケース
    %{
      compared_user: compared_user,
      select_label_compared_user: select_label,
      skill_panel: skill_panel,
      class: class,
      skill_gem_labels: skill_gem_labels
    } = socket.assigns

    # データ取得後に現ジェムの表示名一致をみてデータを決定している。
    # 背景: 指定タイムラインが異なる場合にスキルユニット一致の保証がない
    skill_gem = get_skill_gem(compared_user.id, skill_panel.id, class, select_label)
    value_by_label = Map.new(skill_gem, &{&1.name, &1.percentage})
    skill_gem_data = Enum.map(skill_gem_labels, &Map.get(value_by_label, &1, 0))

    update(socket, :skill_gem_data, fn
      [myself, _] when is_list(myself) -> [myself, skill_gem_data]
      [myself] -> [myself, skill_gem_data]
    end)
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
    data_changed?(prev_assigns, new_assigns, :compared_user) ||
      data_changed?(prev_assigns, new_assigns, :select_label_compared_user) ||
      data_changed?(prev_assigns, new_assigns, :class)
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
