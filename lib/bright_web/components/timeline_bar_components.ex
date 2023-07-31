defmodule BrightWeb.TimelineBarComponents do
  @moduledoc """
  TimelineBar Components
  """
  use Phoenix.Component

  @doc """
  Renders a Timeline Bar

  ## Examples
      <.timeline_bar type="myself" dates={["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"]} selected_date="2023.12" display_now/>
  """
  attr :id, :string
  attr :dates, :list, default: []
  attr :selected_date, :string, default: ""
  attr :type, :string, default: "myself", values: ["myself", "other"]
  attr :display_now, :boolean, default: false
  attr :target, :any, default: nil

  def timeline_bar(assigns) do
    ~H"""
    <div class="flex">
      <div class="w-14"></div>
      <div
        class="bg-brightGray-50 h-[70px] rounded-full w-[714px] my-5 flex justify-around items-center relative" >

        <.close_button
         :if={@type == "other"}
         id={@id}
         target={@target}
        />

        <%= for date <- @dates do %>
          <.date_button
            id={@id}
            target={@target}
            date={date}
            type={@type}
            selected={date == @selected_date}
           />
        <% end %>

        <.now_button
          :if={@display_now}
          id={@id}
          target={@target}
          selected={"now" == @selected_date}
        />

      </div>
      <div class="flex justify-center items-center ml-2"></div>
    </div>
    """
  end

  attr :id, :string
  attr :date, :string
  attr :selected, :boolean
  attr :type, :string
  attr :target, :any, default: nil

  defp date_button(%{selected: true} = assigns) do
    color = check_color(assigns.type)

    style =
      "h-28 w-28 rounded-full #{color.bg} border-white border-8 shadow #{color.text} font-bold text-sm flex justify-center items-center flex-col"

    assigns =
      assigns
      |> assign(:style, style)

    ~H"""
    <div class="h-28 w-28 flex justify-center items-center">
      <button
        phx-click="timeline_bar_button_click"
        phx-target={@target}
        phx-value-id={@id}
        phx-value-data={@date}
        class={@style}
      >
        <span class="material-icons !text-4xl !font-bold" >check</span>
        <%= @date %>
      </button>
    </div>
    """
  end

  defp date_button(assigns) do
    ~H"""
    <div class="h-28 w-28 flex justify-center items-center">
      <button
        phx-click="timeline_bar_button_click"
        phx-target={@target}
        phx-value-id={@id}
        phx-value-data={@date}
        class="h-16 w-16 rounded-full bg-white text-xs flex justify-center items-center"
      >
        <%= @date %>
      </button>
    </div>
    """
  end

  attr :id, :string
  attr :selected, :boolean
  attr :target, :any, default: nil

  defp now_button(%{selected: true} = assigns) do
    ~H"""
    <div
      class="h-28 w-28 flex justify-center items-center absolute right-[86px]">
      <button
        phx-click="timeline_bar_button_click"
        phx-target={@target}
        phx-value-id={@id}
        phx-value-data="now"
        class="h-28 w-28 rounded-full bg-attention-50 border-white border-8 shadow text-attention-900 font-bold text-sm flex justify-center items-center flex-col"
      >
        <span class="material-icons !text-4xl !font-bold">check</span>
        現在
      </button>
    </div>
    """
  end

  defp now_button(assigns) do
    ~H"""
    <div
      class="h-28 w-28 flex justify-center items-center absolute right-[86px]">
      <button
        phx-click="timeline_bar_button_click"
        phx-target={@target}
        phx-value-id={@id}
        phx-value-data="now"
        class="h-10 w-10 rounded-full bg-white text-xs text-attention-900 flex justify-center items-center"
      >
        現在
      </button>
    </div>
    """
  end

  defp close_button(assigns) do
    ~H"""
    <button
      phx-click="timeline_bar_close_button_click"
      phx-target={@target}
      phx-value-id={@id}
      class="absolute right-0 -top-2 border rounded-full w-6 h-6 flex justify-center items-center bg-white border-brightGray-200"
    >
      <span class="material-icons !text-base !text-brightGray-200">close</span>
    </button>
    """
  end

  defp check_color("myself"), do: %{bg: "bg-brightGreen-50", text: "text-brightGreen-600"}
  defp check_color("other"), do: %{bg: "bg-amethyst-50", text: "text-amethyst-600"}
end
