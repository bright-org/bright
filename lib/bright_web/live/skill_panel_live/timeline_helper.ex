defmodule BrightWeb.SkillPanelLive.TimelineHelper do
  @moduledoc """
  タイムラインバー表示のためのデータ作成用の共通処理
  表示用データは以下の通り。

  labels: 表示するラベル。ただし「現在」は含まない
  selected_label: 選択されているラベル。ただし「現在」に関しては"now"で格納
  future_enabled: これ以上の未来を考慮できるかどうかのフラグ
  past_enabled: これ以上の過去を考慮できるかどうかのフラグ
  display_now: 「現在」ボタンを表示するかどうかのフラグ
  """

  # スタートはElixirスキルシート(Excel)の運用開始日時
  @start_label "2021.10"
  @start_month 10
  @monthly_interval 3
  @num_labels 5

  def get_current do
    future_date = get_future_month()
    start_date = future_date |> Timex.shift(months: -1 * @monthly_interval * (@num_labels - 1))
    {_, labels} = create_months(start_date, 0)
    future_enabled = future_enabled?(labels, future_date)
    past_enabled = past_enabled?(labels)

    %{
      future_date: future_date,
      start_date: start_date,
      labels: labels,
      selected_label: "now",
      future_enabled: future_enabled,
      past_enabled: past_enabled,
      display_now: !future_enabled
    }
  end

  def select_label(timeline, label) do
    timeline
    |> Map.put(:selected_label, label)
  end

  def shift_for_future(timeline) do
    {start_date, labels} = create_months(timeline.start_date, @monthly_interval)
    future_enabled = future_enabled?(labels, timeline.future_date)
    past_enabled = past_enabled?(labels)

    timeline
    |> Map.merge(%{
      start_date: start_date,
      labels: labels,
      future_enabled: future_enabled,
      past_enabled: past_enabled,
      display_now: !future_enabled
    })
  end

  def shift_for_past(timeline) do
    {start_date, labels} = create_months(timeline.start_date, -1 * @monthly_interval)
    future_enabled = future_enabled?(labels, timeline.future_date)
    past_enabled = past_enabled?(labels)

    timeline
    |> Map.merge(%{
      start_date: start_date,
      labels: labels,
      future_enabled: future_enabled,
      past_enabled: past_enabled,
      display_now: !future_enabled
    })
  end

  def get_monthly_interval, do: @monthly_interval
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

  defp create_months(current_start_date, shift_month) do
    start_date =
      current_start_date
      |> Timex.shift(months: shift_month)

    labels =
      0..(@num_labels - 1)
      |> Enum.map(fn nth ->
        start_date
        |> Timex.shift(months: @monthly_interval * nth)
        |> date_to_label()
      end)

    {start_date, labels}
  end

  defp month_shiht_add(year, month) when month > 24, do: {year + 2, month - 24, 1}
  defp month_shiht_add(year, month) when month > 12, do: {year + 1, month - 12, 1}
  defp month_shiht_add(year, month) when month <= 12, do: {year, month, 1}

  defp date_to_label(data), do: "#{data.year}.#{data.month}"

  defp future_enabled?(labels, future) do
    List.last(labels) != date_to_label(future)
  end

  defp past_enabled?(labels) do
    List.first(labels) != @start_label
  end
end
