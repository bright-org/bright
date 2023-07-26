defmodule BrightWeb.CardLive.CardListComponents do
  @moduledoc """
  Card List Components
  """
  use Phoenix.Component

  @hour 60
  @day @hour * 24
  @highlight_minutes @hour * 8

  @doc """
  Renders a Card Row

  ## Examples
      <.card_row notification={notification} type="contact" />
  """
  attr :notification, :map, required: true
  attr :type, :string, values: ["contact", "communication"]

  def card_row(%{type: "contact"} = assigns) do
    ~H"""
    <li class="text-left flex items-center text-base">
      <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
        <%= @notification.icon_type %>
      </span>
      <%= @notification.message %>
      <.elapsed_time inserted_at={@notification.inserted_at}/>
    </li>
    """
  end

  def card_row(%{type: "communication"} = assigns) do
    ~H"""
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 px-1">
      <span class="material-icons-outlined !text-sm !text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
        <%= @notification.icon_type %>
      </span>
      <%= @notification.message %>
      <.elapsed_time inserted_at={@notification.inserted_at}/>
    </li>
    """
  end

  attr :inserted_at, :any

  defp elapsed_time(assigns) do
    {:ok, inserted_at} = DateTime.from_naive(assigns.inserted_at, "Etc/UTC")

    minutes =
      DateTime.diff(DateTime.utc_now(), inserted_at, :minute)
      |> trunc()

    style = highlight(minutes < @highlight_minutes) <> " font-bold pl-4 inline-block"

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
