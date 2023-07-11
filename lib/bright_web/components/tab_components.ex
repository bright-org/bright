defmodule BrightWeb.TabComponents do
  @moduledoc """
  Tab Components
  """
  use Phoenix.Component

  @doc """
  Renders a Tab

  ## Examples
      <tab />
  """
  attr :tabs, :list
  slot :inner_block
  attr :selected_index, :integer, default: 0
  attr :previous_enable, :boolean, default: false
  attr :next_enable, :boolean, default: false
  attr :menu_enable, :boolean, default: false

  def tab(assigns) do
    ~H"""
    <div class="bg-white rounded-md mt-1">
      <div class="text-sm font-medium text-center text-brightGray-200">
        <.tab_header tabs={@tabs} selected_index={@selected_index} menu_enable={@menu_enable}/>
        <div class="pt-4 pb-1 px-8">
          <%= render_slot(@inner_block) %>
        </div>
        <.tab_footer previous_enable={@previous_enable} next_enable={@next_enable}/>
      </div>
    </div>
    """
  end

  attr :tabs, :list
  attr :selected_index, :integer, default: 0
  attr :menu_enable, :boolean, default: false

  def tab_header(assigns) do
    ~H"""
    <ul class="flex content-between border-b border-brightGray-50">
      <%= for {item, index} <- Enum.with_index(assigns.tabs) do %>
        <.tab_header_item selected={index == assigns.selected_index}> <%= item %></.tab_header_item>
      <% end %>
      <%= if assigns.menu_enable do %>
        <.tab_menu_button />
      <% end %>
    </ul>
    """
  end

  slot :inner_block
  attr :selected, :boolean, default: false

  def tab_header_item(assigns) do
    style = "py-3.5 w-full items-center justify-center inline-block"
    selected_style = " text-brightGreen-300 font-bold border-brightGreen-300 border-b-2"
    style = if assigns.selected, do: style <> selected_style, else: style

    assigns =
      assigns
      |> assign(:style, style)

    ~H"""
    <li class="w-full">
      <a href="#" phx-click="tab_click" class={@style}>
        <%= render_slot(@inner_block) %>
      </a>
    </li>
    """
  end

  def tab_menu_button(assigns) do
    ~H"""
    <li class="flex items-center">
      <button
        type="button"
        id="dropmenu01"
        data-dropdown-toggle="menu01"
        class="text-black rounded-full w-10 h-10 inline-flex items-center justify-center"
      >
        <span class="material-icons text-xs text-brightGreen-900">more_vert</span>
      </button>
      <!-- Dropdown menu -->
      <.tab_menu />
    </li>
    """
  end

  attr :previous_enable, :boolean
  attr :next_enable, :boolean

  def tab_footer(assigns) do
    previous_button_style =
      "#{page_button_enable_style(assigns.previous_enable)} bg-white px-3 py-1.5 inline-flex font-medium rounded-md text-sm items-center"

    next_button_style =
      "#{page_button_enable_style(assigns.next_enable)} bg-white px-3 py-1.5 inline-flex font-medium rounded-md text-sm items-center"

    previous_span_style =
      "material-icons md-18 mr-2 #{page_button_enable_style(assigns.previous_enable)}"

    next_span_style = "material-icons md-18 ml-2 #{page_button_enable_style(assigns.next_enable)}"

    assigns =
      assigns
      |> assign(:previous_button_style, previous_button_style)
      |> assign(:next_button_style, next_button_style)
      |> assign(:previous_span_style, previous_span_style)
      |> assign(:next_span_style, next_span_style)

    ~H"""
    <div class="flex justify-center gap-x-14 pb-3">
      <button
        type="button"
        class={@previous_button_style}
      >
        <span class={@previous_span_style} >chevron_left</span> 前
      </button>
      <button
        type="button"
        class={@next_button_style}
      >
        次 <span class={@next_span_style} >chevron_right</span>
      </button>
    </div>
    """
  end

  defp page_button_enable_style(true), do: "text-brightGray-900"
  defp page_button_enable_style(false), do: "text-brightGray-200"

  attr :menu_items, :list

  def tab_menu(assigns) do
    ~H"""
    <div
      id="menu01"
      class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700"
    >
      <ul class="py-2 text-sm text-gray-700 dark:text-gray-200" aria-labelledby="dropmenu01">
      <.tab_menu_item />

      </ul>
    </div>
    """
  end

  attr :menu_item, :map, default: %{text: "メニュー", href: "/storybook"}

  def tab_menu_item(assigns) do
    ~H"""
        <li>
          <a
            href={@menu_item.href}
            class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
          >
            <%= assigns.menu_item.text %>
          </a>
        </li>
    """
  end
end
