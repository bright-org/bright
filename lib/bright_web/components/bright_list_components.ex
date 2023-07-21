defmodule BrightWeb.BrightListComponents do
  @moduledoc """
  Bright List Components
  """
  use Phoenix.Component

  @highlight_minutes 60 * 8

  @doc """
  Renders a contact Row

  ## Examples
      <.contact_card_row />
  """
  def contact_card_row(assigns) do
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

  attr :notification, :map, required: true

  def communication_card_row(assigns) do
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

    time_text = if minutes < 60, do: "#{minutes}分前", else: "#{trunc(minutes / 60)}時間前"

    style = highlight(minutes < @highlight_minutes) <> " font-bold pl-4 inline-block"

    assigns =
      assigns
      |> assign(:style, style)
      |> assign(:time_text, time_text)

    ~H"""
    <span class={@style}><%= @time_text %></span>
    """
  end

  defp highlight(true), do: "text-brightGreen-300"
  defp highlight(false), do: "text-brightGray-300"
end
