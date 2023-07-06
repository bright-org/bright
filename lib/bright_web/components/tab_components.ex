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
  def tab(assigns) do
    ~H"""
    <div class="bg-white rounded-md mt-1">
      <div class="text-sm font-medium text-center text-brightGray-200">
        <ul class="flex content-between border-b border-brightGray-50">
          <li class="w-full">
            <a
              href="#"
              class="py-3.5 w-full items-center justify-center inline-block text-brightGreen-300 font-bold border-brightGreen-300 border-b-2"
            >
              tab1
            </a>
          </li>
          <li class="w-full">
            <a href="#" class="py-3.5 w-full items-center justify-center inline-block">
              tab2
            </a>
          </li>
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
        </ul>
        <div class="pt-4 pb-1 px-8">
          内容
        </div>
        <.tab_footer />
      </div>
    </div>
    """
  end

  def tab_footer(assigns) do
    ~H"""
    <div class="flex justify-center gap-x-14 pb-3">
      <button
        type="button"
        class="text-brightGray-200 bg-white px-3 py-1.5 inline-flex font-medium rounded-md text-sm items-center"
      >
        <span class="material-icons md-18 mr-2 text-brightGray-200">chevron_left</span> 前
      </button>
      <button
        type="button"
        class="text-brightGray-900 bg-white px-3 py-1.5 inline-flex font-medium rounded-md text-sm items-center"
      >
        次 <span class="material-icons md-18 ml-2 text-brightGray-900">chevron_right</span>
      </button>
    </div>
    """
  end

  def tab_menu(assigns) do
    ~H"""
    <div
      id="menu01"
      class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700"
    >
      <ul class="py-2 text-sm text-gray-700 dark:text-gray-200" aria-labelledby="dropmenu01">
        <li>
          <a
            href="#"
            class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
          >
            menu1-1
          </a>
        </li>
      </ul>
    </div>
    """
  end
end
