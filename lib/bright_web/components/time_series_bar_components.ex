defmodule BrightWeb.TimeSeriesBarComponents do
  @moduledoc """
  TimeSeriesBar Components
  """
  use Phoenix.Component

  @doc """
  Renders a Time Series Bar

  ## Examples
      <.time_series_bar

      />
  """

  attr :dates, :list, default: []
  attr :check_date, :string, default: ""
  attr :user_type, :string, default: "my", values: ["my", "other"]
  attr :display_now, :boolean, default: false

  def time_series_bar(assigns) do
    ~H"""
    <div class="flex">
      <div class="w-14"></div>
      <div
        class="bg-brightGray-50 h-[70px] rounded-full w-[714px] my-5 flex justify-around items-center relative" >

        <%= if @user_type == "other" do %>
         <.close_button />
        <% end %>

        <%= for date <- @dates do %>
          <%= if date == @check_date do %>
            <.check_date_button date={date} user_type={@user_type} />
          <% else %>
            <.date_button date={date} />
          <% end %>
        <% end %>

        <%= if @display_now do %>
          <%= if "now" == @check_date do %>
            <.check_now_button />
          <% else %>
            <.now_button />
          <% end %>
        <% end %>

      </div>
      <div class="flex justify-center items-center ml-2"></div>
    </div>
    """
  end

  attr :date, :string, default: ""

  defp date_button(assigns) do
    ~H"""
    <div class="h-28 w-28 flex justify-center items-center">
      <button
        class="h-16 w-16 rounded-full bg-white text-xs flex justify-center items-center">
        <%= @date %>
      </button>
    </div>
    """
  end

  defp now_button(assigns) do
    ~H"""
    <div
      class="h-28 w-28 flex justify-center items-center absolute right-[86px]">
      <button
        class="h-10 w-10 rounded-full bg-white text-xs text-attention-900 flex justify-center items-center"
      >
        現在
      </button>
    </div>
    """
  end

  defp check_now_button(assigns) do
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
  attr :user_type, :string

  defp check_date_button(assigns) do
    color = check_color(assigns.user_type)

    style =
      "h-28 w-28 rounded-full #{color.bg} border-white border-8 shadow #{color.text} font-bold text-sm flex justify-center items-center flex-col"

    assigns =
      assigns
      |> assign(:style, style)

    ~H"""
    <div class="h-28 w-28 flex justify-center items-center">
      <button class={@style}>
        <span class="material-icons !text-4xl !font-bold"
          >check</span>
        <%= @date %>
      </button>
    </div>
    """
  end

  defp close_button(assigns) do
    ~H"""
    <button class="absolute right-0 -top-2 border rounded-full w-6 h-6 flex justify-center items-center bg-white border-brightGray-200">
      <span class="material-icons !text-base !text-brightGray-200">close</span>
    </button>
    """
  end

  defp check_color("my"), do: %{bg: "bg-brightGreen-50", text: "text-brightGreen-600"}
  defp check_color("other"), do: %{bg: "bg-amethyst-50", text: "text-amethyst-600"}
end
