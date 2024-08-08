defmodule BrightWeb.ViewHelper do
  def format_datetime(naive_datetime, "Asia/Tokyo") do
    naive_datetime
    |> NaiveDateTime.add(9, :hour)
    |> NaiveDateTime.to_string()
    |> String.slice(0, 16)
  end
end
