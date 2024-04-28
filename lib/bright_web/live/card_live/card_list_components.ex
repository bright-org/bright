defmodule BrightWeb.CardLive.CardListComponents do
  @moduledoc """
  Card List Components
  """
  use BrightWeb, :component

  @hour 60
  @day @hour * 24
  @highlight_minutes @hour * 8

  attr :inserted_at, :any
  attr :extend_style, :string, default: ""

  def elapsed_time(assigns) do
    {:ok, inserted_at} = DateTime.from_naive(assigns.inserted_at, "Etc/UTC")

    minutes =
      DateTime.diff(DateTime.utc_now(), inserted_at, :minute)
      |> trunc()

    style =
      highlight(minutes < @highlight_minutes) <>
        " font-bold pl-0 inline-block w-full text-sm order-1 lg:pl-4 lg:order-3 lg:w-auto " <>
        assigns.extend_style

    assigns =
      assigns
      |> assign(:style, style)
      |> assign(:time_text, time_text(minutes))

    ~H"""
    <span class={@style}><%= @time_text %></span>
    """
  end

  defp time_text(minutes) when minutes < @hour, do: "#{minutes}分前"
  defp time_text(minutes) when minutes < @day, do: "#{trunc(minutes / @hour)}時間前"
  defp time_text(minutes), do: "#{trunc(minutes / @day)}日前"

  defp highlight(true), do: "text-brightGreen-300"
  defp highlight(false), do: "text-brightGray-300"
end
