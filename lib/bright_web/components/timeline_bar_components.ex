defmodule BrightWeb.TimelineBarComponents do
  @moduledoc """
  TimelineBar Components
  """
  use Phoenix.Component

  @layout_size %{
    "md" => %{height: "h-[52px] lg:h-[70px]", width: "lg:w-[714px]"},
    "sm" => %{height: "h-[52px] lg:h-[44px]", width: "lg:w-[500px]"}
  }

  @button_outer_size %{
    "md" => %{height: "lg:h-28", width: "lg:w-28"},
    "sm" => %{height: "lg:h-[80px]", width: "lg:w-[80px]"}
  }

  @button_size %{
    "md" => %{height: "lg:h-16", width: "lg:w-16"},
    "sm" => %{height: "lg:h-[56px]", width: "lg:w-[56px]"}
  }

  @button_selected_size %{
    "md" => %{height: "lg:h-28", width: "lg:w-28"},
    "sm" => %{height: "lg:h-[80px]", width: "lg:w-[80px]"}
  }

  @button_selected_font_size %{
    "md" => %{whole: "text-sm", check: "!text-4xl"},
    "sm" => %{whole: "text-xs", check: "!text-[22px]"}
  }

  @button_now_size %{
    "md" => %{height: "lg:h-10", width: "lg:w-10"},
    "sm" => %{height: "lg:h-[38px]", width: "lg:w-[38px]"}
  }

  @button_now_position %{
    "md" => "lg:right-[86px]",
    "sm" => "lg:right-[58px]"
  }

  @button_style %{
    "md" => "",
    "sm" => "border border-brightGray-50 font-bold"
  }

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
  attr :display_close, :boolean, default: false
  attr :target, :any, default: nil
  attr :scale, :string, default: "md"

  def timeline_bar(assigns) do
    ~H"""
    <div
      class={["bg-brightGray-50 rounded-full my-5 flex justify-around items-center relative w-full", layout_scale_class(@scale)]}>
      <.close_button
       :if={@display_close}
       id={@id}
       target={@target}
      />

      <%= for date <- Enum.slice(@dates, 0, 4) do %>
        <.date_button
          id={@id}
          target={@target}
          date={date}
          type={@type}
          selected={date == @selected_date}
          scale={@scale}
         />
      <% end %>

      <.now_button
        :if={@display_now}
        id={@id}
        target={@target}
        selected={"now" == @selected_date}
        scale={@scale}
      />
    </div>
    """
  end

  attr :id, :string
  attr :date, :string
  attr :selected, :boolean
  attr :type, :string
  attr :target, :any
  attr :scale, :string

  defp date_button(%{selected: true} = assigns) do
    color = check_color(assigns.type)
    %{whole: font_whole, check: font_check} = button_selected_font_class(assigns.scale)

    style =
      "#{button_selected_scale_class(assigns.scale)} rounded-full #{color.bg} border-white border-8 shadow #{color.text} font-bold #{font_whole} flex justify-center items-center flex-col h-12 w-12 text-xs"

    assigns =
      assigns
      |> assign(:style, style)
      |> assign(:font_check, font_check)

    ~H"""
    <div class={["flex justify-center items-center h-24 w-24", button_outer_scale_class(@scale)]}>
      <button
        phx-click="timeline_bar_button_click"
        phx-value-id={@id}
        phx-value-date={@date}
        phx-target={@target}
        class={@style}
      >
        <span class={["material-icons !font-bold !text-xl lg:!text-4xl", @font_check]}>check</span>
        <%= @date %>
      </button>
    </div>
    """
  end

  defp date_button(assigns) do
    ~H"""
    <div class={["flex justify-center items-center h-24 w-24", button_outer_scale_class(@scale)]}>
      <button
        phx-click="timeline_bar_button_click"
        phx-value-id={@id}
        phx-value-date={@date}
        phx-target={@target}
        class={["rounded-full bg-white text-xs flex justify-center items-center h-12 w-12 lg:h-16 lg:w-16", button_scale_class(@scale), button_style_class(@scale)]}
      >
        <%= @date %>
      </button>
    </div>
    """
  end

  attr :id, :string
  attr :selected, :boolean
  attr :target, :any
  attr :scale, :string

  defp now_button(%{selected: true} = assigns) do
    assigns =
      assigns
      |> assign(:font, button_selected_font_class(assigns.scale))

    ~H"""
    <div
      class={["flex justify-center items-center absolute h-[52px] w-[52px] right-[38px]", button_outer_scale_class(@scale), button_now_position_class(@scale)]}>
      <button
        phx-click="timeline_bar_button_click"
        phx-value-id={@id}
        phx-value-date="now"
        phx-target={@target}
        class={["rounded-full bg-attention-50 border-white border-8 shadow text-attention-900 font-bold flex justify-center items-center flex-col h-[44px] w-[44px] text-sm", button_selected_scale_class(@scale), @font.whole]}
      >
        <span class={["-mb-1 lg:mb-0 material-icons !font-bold !text-xl lg:!text-4xl", @font.check]}>check</span>
        現在
      </button>
    </div>
    """
  end

  defp now_button(assigns) do
    ~H"""
    <div
      class={["flex justify-center items-center absolute  h-[52px] w-[52px] right-[38px]", button_outer_scale_class(@scale), button_now_position_class(@scale)]}>
      <button
        phx-click="timeline_bar_button_click"
        phx-value-id={@id}
        phx-value-date="now"
        phx-target={@target}
        class={["rounded-full bg-white text-xs text-attention-900 flex justify-center items-center h-[44px] w-[44px]", button_now_scale_class(@scale), button_style_class(@scale)]}
      >
        現在
      </button>
    </div>
    """
  end

  attr :id, :string
  attr :target, :any

  defp close_button(assigns) do
    ~H"""
    <button
      phx-click="timeline_bar_close_button_click"
      phx-value-id={@id}
      phx-target={@target}
      class="absolute right-0 -top-2 border rounded-full w-6 h-6 flex justify-center items-center bg-white border-brightGray-200"
    >
      <span class="material-icons !text-base !text-brightGray-200">close</span>
    </button>
    """
  end

  defp check_color("myself"), do: %{bg: "bg-brightGreen-50", text: "text-brightGreen-600"}
  defp check_color("other"), do: %{bg: "bg-amethyst-50", text: "text-amethyst-600"}

  defp layout_scale_class(scale) do
    [
      get_in(@layout_size, [scale, :height]),
      get_in(@layout_size, [scale, :width])
    ]
    |> Enum.join(" ")
  end

  defp button_outer_scale_class(scale) do
    [
      get_in(@button_outer_size, [scale, :height]),
      get_in(@button_outer_size, [scale, :width])
    ]
    |> Enum.join(" ")
  end

  defp button_scale_class(scale) do
    [
      get_in(@button_size, [scale, :height]),
      get_in(@button_size, [scale, :width])
    ]
    |> Enum.join(" ")
  end

  defp button_selected_scale_class(scale) do
    [
      get_in(@button_selected_size, [scale, :height]),
      get_in(@button_selected_size, [scale, :width])
    ]
    |> Enum.join(" ")
  end

  defp button_now_scale_class(scale) do
    [
      get_in(@button_now_size, [scale, :height]),
      get_in(@button_now_size, [scale, :width])
    ]
    |> Enum.join(" ")
  end

  defp button_selected_font_class(scale) do
    get_in(@button_selected_font_size, [scale])
  end

  defp button_now_position_class(scale) do
    get_in(@button_now_position, [scale])
  end

  defp button_style_class(scale) do
    get_in(@button_style, [scale])
  end
end
