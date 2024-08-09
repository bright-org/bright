defmodule BrightWeb.ViewHelper do
  @moduledoc """
  汎用的な表示用のヘルパー
  """

  def format_datetime(naive_datetime, "Asia/Tokyo", string_format \\ "%Y-%m-%d %H:%M") do
    naive_datetime
    |> NaiveDateTime.add(9, :hour)
    |> Calendar.strftime(string_format)
  end
end
