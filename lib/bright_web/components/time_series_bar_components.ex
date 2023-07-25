defmodule BrightWeb.TimeSeriesBarComponents do
  @moduledoc """
  Profile Components
  """
  use Phoenix.Component

  @doc """
  Renders a Time Series Bar

  ## Examples
      <.time_series_bar

      />
  """

  attr :dates, :list, default: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"]
  attr :check_date, :string, default: "2022.12"

  def time_series_bar(assigns) do
    ~H"""
    <div class="flex">
      <div class="w-14"></div>
      <div
        class="bg-brightGray-50 h-[70px] rounded-full w-[714px] my-5 flex justify-around items-center relative" >

        <%= for date <- @dates do %>
          <%= if date == @check_date do %>
            <.check_date_button date={date} />
          <% else %>
            <.date_button date={date} />
          <% end %>
        <% end %>

        <%= if "now" == @check_date do %>
          <.check_now_button />
        <% else %>
          <.now_button />
        <% end %>

      </div>
      <div class="flex justify-center items-center ml-2"></div>
    </div>
    """
  end

  attr :date, :string, default: ""

  def date_button(assigns) do
    ~H"""
    <div class="h-28 w-28 flex justify-center items-center">
      <button
        class="h-16 w-16 rounded-full bg-white text-xs flex justify-center items-center">
        <%= @date %>
      </button>
    </div>
    """
  end

  def now_button(assigns) do
    ~H"""
    <div
      class="h-28 w-28 flex justify-center items-center absolute right-[58px]">
      <button
        class="h-10 w-10 rounded-full bg-white text-xs text-attention-900 flex justify-center items-center"
      >
        現在
      </button>
    </div>
    """
  end

  def check_now_button(assigns) do
    ~H"""
    <div
      class="h-28 w-28 flex justify-center items-center absolute right-[86px]">
      <button
        class="h-28 w-28 rounded-full bg-attention-50 border-white border-8 shadow text-attention-900 font-bold text-sm flex justify-center items-center flex-col"
      >
        <span class="material-icons !text-4xl !font-bold"
          >check</span>
        現在
      </button>
    </div>
    """
  end

  attr :date, :string, default: ""

  def check_date_button(assigns) do
    ~H"""
    <div class="h-28 w-28 flex justify-center items-center">
      <button
        class="h-28 w-28 rounded-full bg-brightGreen-50 border-white border-8 shadow text-brightGreen-600 font-bold text-sm flex justify-center items-center flex-col"
      >
        <span class="material-icons !text-4xl !font-bold"
          >check</span>
        <%= @date %>
      </button>
    </div>
    """
  end
end
