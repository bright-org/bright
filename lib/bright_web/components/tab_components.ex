# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新

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
  # TODO id, :string, default: "tab01"のdefaultはいずれ削除
  attr :id, :string, default: "tab01"
  attr :tabs, :list
  slot :inner_block
  attr :selected_tab, :string, default: ""
  attr :previous_enable, :boolean, default: false
  attr :next_enable, :boolean, default: false
  attr :menu_items, :list, default: []
  attr :inner_tab, :boolean, default: false
  attr :page, :integer, default: 1
  attr :total_pages, :integer, default: 1
  attr :hidden_footer, :boolean, default: false
  attr :target, :any, default: nil

  def tab(assigns) do
    ~H"""
    <div class="bg-white rounded-md mt-1">
      <div class="text-sm font-medium text-center text-brightGray-500">
        <.tab_header id={@id} tabs={@tabs} selected_tab={@selected_tab} menu_items={@menu_items} target={@target}/>
        <%= if @inner_tab do %>
          <.inner_tab />
        <% end %>
        <%= render_slot(@inner_block) %>
        <%= if !@hidden_footer do %>
          <.tab_footer id={@id} page={@page} total_pages={@total_pages} target={@target} />
        <% end %>
      </div>
    </div>
    """
  end

  attr :id, :string
  attr :tabs, :list
  attr :selected_tab, :string, default: ""
  attr :menu_items, :list
  attr :target, :any

  defp tab_header(assigns) do
    ~H"""
    <ul class="flex content-between border-b border-brightGray-200">
      <%= for {key, value} <- @tabs do %>
        <.tab_header_item id={@id}  tab_name={key} selected={key == @selected_tab} target={@target}> <%= value %></.tab_header_item>
      <% end %>
      <%= if length(@menu_items) > 0 do %>
        <.tab_menu_button id={@id} menu_items={@menu_items}/>
      <% end %>
    </ul>
    """
  end

  attr :id, :string
  attr :tab_name, :string
  attr :selected, :boolean
  slot :inner_block
  attr :target, :any

  defp tab_header_item(assigns) do
    style = "py-3.5 w-full items-center justify-center inline-block"
    selected_style = " text-brightGreen-300 font-bold border-brightGreen-300 border-b-2"
    style = if assigns.selected, do: style <> selected_style, else: style

    assigns =
      assigns
      |> assign(:style, style)

    ~H"""
    <li class="w-full">
      <a href="#" phx-click="tab_click" phx-target={@target} phx-value-id={@id} phx-value-tab_name={@tab_name} class={@style}>
        <%= render_slot(@inner_block) %>
      </a>
    </li>
    """
  end

  attr :id, :string
  attr :menu_items, :list

  defp tab_menu_button(assigns) do
    assigns =
      assigns
      |> assign(:data_dropdown_toggle, assigns.id <> "_menu")
      |> assign(:button_id, assigns.id <> "_dropmenu")

    ~H"""
    <li class="flex items-center">
      <button
        type="button"
        id={@button_id}
        data-dropdown-toggle={@data_dropdown_toggle}
        class="text-black rounded-full w-10 h-10 inline-flex items-center justify-center"
      >
        <span class="material-icons text-brightGreen-900">more_vert</span>
      </button>
      <!-- Dropdown menu -->
      <.tab_menu id={@id} menu_items={@menu_items}/>
    </li>
    """
  end

  attr :menu_items, :list
  attr :id, :string

  defp tab_menu(assigns) do
    assigns =
      assigns
      |> assign(:menu_id, assigns.id <> "_menu")
      |> assign(:aria_labelledby, assigns.id <> "_dropmenu")

    ~H"""
    <div
      id={@menu_id}
      class="z-10 hidden bg-white rounded-lg shadow-md min-w-[286px]"
    >
      <ul class="p-2 text-left text-base" aria-labelledby={@aria_labelledby}>
        <%= for menu_item <- @menu_items do %>
          <.tab_menu_item menu_item={menu_item}/>
        <% end %>
      </ul>
    </div>
    """
  end

  attr :menu_item, :map

  defp tab_menu_item(assigns) do
    style = "block px-4 py-3 hover:bg-brightGray-50 text-base hover:cursor-pointer"

    assigns =
      assigns
      |> assign(:style, style)

    ~H"""
        <li>
        <%= if Map.has_key?(@menu_item, :href) do %>
          <a
            href={@menu_item.href}
            class={@style}
          >
            <%= @menu_item.text %>
          </a>
        <% end %>
        <%= if Map.has_key?(@menu_item, :on_click) do %>
        <a
            phx-click={@menu_item.on_click}
            class={@style}
          >
            <%= @menu_item.text %>
          </a>
        <% end %>
        </li>
    """
  end

  attr :id, :string
  attr :page, :integer
  attr :total_pages, :integer
  attr :target, :any

  defp tab_footer(assigns) do
    previous_enable = assigns.page > 1
    next_enable = assigns.page < assigns.total_pages

    previous_button_style =
      "#{page_button_enable_style(previous_enable)} bg-white px-3 py-1.5 inline-flex font-medium rounded-md text-sm items-center"

    next_button_style =
      "#{page_button_enable_style(next_enable)} bg-white px-3 py-1.5 inline-flex font-medium rounded-md text-sm items-center"

    previous_span_style = "material-icons md-18 mr-2 #{page_button_enable_style(previous_enable)}"

    next_span_style = "material-icons md-18 ml-2 #{page_button_enable_style(next_enable)}"

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
        phx-click="previous_button_click"
        phx-target={@target}
        phx-value-id={@id}
      >
        <span class={@previous_span_style} >chevron_left</span> 前
      </button>
      <button
        type="button"
        class={@next_button_style}
        phx-click="next_button_click"
        phx-target={@target}
        phx-value-id={@id}
      >
        次 <span class={@next_span_style} >chevron_right</span>
      </button>
    </div>
    """
  end

  defp page_button_enable_style(true), do: "text-brightGray-900"
  defp page_button_enable_style(false), do: "text-brightGray-200"

  defp inner_tab(assigns) do
    ~H"""
    <!-- tab2 -->
    <div class="overflow-hidden">
      <ul
        class="flex border-b border-brightGray-50 text-base !text-sm w-[800px]"
      >
        <li class="py-2 w-[200px] border-r border-brightGray-50">
          キャリアの参考になる方々
        </li>
        <li
          class="py-2 w-[200px] border-r border-brightGray-50 bg-brightGreen-50"
        >
          優秀なエンジニアの方々
        </li>
        <li class="py-2 w-[200px] border-r border-brightGray-50">
          カスタムグループ３
        </li>
        <li class="py-2 w-[200px] border-r border-brightGray-50">
          カスタムグループ４
        </li>
      </ul>
    </div>
    """
  end
end
