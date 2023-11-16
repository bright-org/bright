defmodule BrightWeb.TimelineHelper do
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
  # month_range_size: タイムラインに表示される月幅
  @month_range_size @monthly_interval * (@num_labels - 1)
  @valid_months [1, 4, 7, 10]

  def get_current do
    get_by_date("now")
  end

  @doc """
  label(例: `2023.10`)からtimelineを構築して返す。
  ただし、labelはユーザー入力として受けるため不適切な場合は現在時刻で返す。
  """
  def get_by_label(label) do
    with date when not is_nil(date) <- label_to_date(label),
         true <- Date.compare(date, label_to_date(@start_label)) in [:gt, :eq],
         true <- Date.compare(date, Date.utc_today()) in [:lt, :eq],
         true <- date.month in @valid_months do
      get_by_date(label, date)
    else
      v when v in [nil, false] -> get_current()
    end
  end

  def select_label(timeline, label) do
    Map.put(timeline, :selected_label, label)
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

  def select_past_if_label_is_now(%{selected_label: "now"} = timeline) do
    past_label = Enum.at(timeline.labels, -2)
    select_label(timeline, past_label)
  end

  def select_past_if_label_is_now(timeline), do: timeline

  def get_monthly_interval, do: @monthly_interval

  @doc """
  引数dateを起点として引数numで指定したインターバル分をずらした日付を返す
  """
  def get_shift_date_from_date(date, num_shifts) do
    Timex.shift(date, months: num_shifts * @monthly_interval)
  end

  @doc """
  現在選択されているものが「現在」「未来」「過去」のいずれかを返す
  """
  def get_selected_tense(timeline) do
    {timeline.selected_label, timeline.future_enabled, List.last(timeline.labels)}
    |> case do
      {"now", _, _} -> :now
      {selected_label, false, latest_label} when selected_label == latest_label -> :future
      _ -> :past
    end
  end

  @doc """
  指定されたindexの日付を返す
  """
  def get_date_at(timeline, index) do
    timeline.labels
    |> Enum.at(index)
    |> label_to_date()
  end

  def label_to_date(label) when not is_bitstring(label), do: nil

  def label_to_date(<<year::bytes-size(4)>> <> "." <> <<month::binary>>) do
    with {year, ""} <- Integer.parse(year),
         {month, ""} <- Integer.parse(month),
         {:ok, date} <- Date.new(year, month, 1) do
      date
    else
      _ -> nil
    end
  end

  def label_to_date(_label), do: nil

  @doc """
  nowを除く最新日付（ラベル）を返す
  """
  def get_latest_date_label do
    get_by_date("now")
    |> select_past_if_label_is_now()
    |> Map.get(:selected_label)
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

  defp get_by_date(selected_label, date \\ nil) do
    future_date = get_future_month()

    # タイムラインの表示開始日付(start_date)を決定している
    # 未来は表示しないため取りうる最も新しいstart_dateはbase_start_dateになる
    base_start_date = Timex.shift(future_date, months: -1 * @month_range_size)

    start_date =
      if(
        date,
        do: Timex.shift(date, months: -2 * @monthly_interval),
        else: base_start_date
      )

    start_date = Enum.min([start_date, base_start_date], Date)

    {_, labels} = create_months(start_date, 0)
    future_enabled = future_enabled?(labels, future_date)
    past_enabled = past_enabled?(labels)

    %{
      future_date: future_date,
      start_date: start_date,
      labels: labels,
      selected_label: selected_label,
      future_enabled: future_enabled,
      past_enabled: past_enabled,
      display_now: !future_enabled
    }
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
