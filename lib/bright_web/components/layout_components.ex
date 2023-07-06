defmodule BrightWeb.LayoutComponents do
  @moduledoc """
  LayoutComponents
  """
  use Phoenix.Component

  @doc """
  Renders a Head

  ## Examples
      <.header/>
  """
  def head(assigns) do
    ~H"""
    <div class="w-full flex justify-between py-2.5 px-12 border-brightGray-100 border-b bg-brightGray-50">
      <h4>マイページ</h4>
      <div class="flex gap-x-6">
        <button
          type="button"
          id="mega-menu-dropdown-button"
          data-dropdown-toggle="mega-menu-dropdown"
          class="text-black bg-brightGray-100 hover:bg-brightGray-200 rounded-full w-10 h-10 inline-flex items-center justify-center"
        >
          <span class="material-icons text-xs">search</span>
        </button>
        <button
          type="button"
          class="text-black bg-brightGray-100 hover:bg-brightGray-200 rounded-full w-10 h-10 inline-flex items-center justify-center relative"
        >
          <span class="material-icons text-xs">notifications_none</span>
          <div class="absolute inline-flex items-center justify-center w-5 h-5 text-xs font-bold text-white bg-attention-600 rounded-full -top-0 -right-2">
            1
          </div>
        </button>
        <img
          class="inline-block h-10 w-10 rounded-full"
          src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
        />
        <button
          type="button"
          class="text-black bg-brightGray-100 hover:bg-brightGray-200 rounded-full w-10 h-10 inline-flex items-center justify-center"
        >
          <span class="material-icons text-xs">settings</span>
        </button>
      </div>
    </div>
    <div
      id="mega-menu-dropdown"
      class="absolute hidden z-10 w-[1000px] !top-1 min-h-full grid-cols-2 text-sm bg-white shadow-md dark:border-gray-700 md:grid-cols-3 dark:bg-gray-700"
    >
      <div class="p-4 pb-0 text-gray-900 md:pb-4 dark:text-white">
        <ul class="space-y-4" aria-labelledby="mega-menu-dropdown-button">
          <li>
            <a
              href="#"
              class="text-gray-500 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-500"
            >
              About Us
            </a>
          </li>
          <li>
            <a
              href="#"
              class="text-gray-500 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-500"
            >
              Library
            </a>
          </li>
          <li>
            <a
              href="#"
              class="text-gray-500 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-500"
            >
              Resources
            </a>
          </li>
          <li>
            <a
              href="#"
              class="text-gray-500 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-500"
            >
              Pro Version
            </a>
          </li>
        </ul>
      </div>
      <div class="p-4 pb-0 text-gray-900 md:pb-4 dark:text-white">
        <ul class="space-y-4">
          <li>
            <a
              href="#"
              class="text-gray-500 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-500"
            >
              Blog
            </a>
          </li>
          <li>
            <a
              href="#"
              class="text-gray-500 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-500"
            >
              Newsletter
            </a>
          </li>
          <li>
            <a
              href="#"
              class="text-gray-500 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-500"
            >
              Playground
            </a>
          </li>
          <li>
            <a
              href="#"
              class="text-gray-500 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-500"
            >
              License
            </a>
          </li>
        </ul>
      </div>
      <div class="p-4">
        <ul class="space-y-4">
          <li>
            <a
              href="#"
              class="text-gray-500 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-500"
            >
              Contact Us
            </a>
          </li>
          <li>
            <a
              href="#"
              class="text-gray-500 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-500"
            >
              Support Center
            </a>
          </li>
          <li>
            <a
              href="#"
              class="text-gray-500 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-500"
            >
              Terms
            </a>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
