defmodule BrightWeb.ContactCardComponents do
  @moduledoc """
  Profile Components
  """
  use Phoenix.Component

  @doc """
  Renders a Contact

  ## Examples
      <.contact_card/>
  """
  def contact_card(assigns) do
    ~H"""
    <div>
      <h5>他ユーザーやチームからの連絡</h5>
      <div class="bg-white rounded-md mt-1">
        <div class="text-sm font-medium text-center text-brightGray-200">
          <ul class="flex content-between border-b border-brightGray-50">
            <li class="w-full">
              <a
                href="#"
                class="py-3.5 w-full items-center justify-center inline-block text-brightGreen-300 font-bold border-brightGreen-300 border-b-2"
              >
                採用（仮置き）
              </a>
            </li>
            <li class="w-full">
              <a href="#" class="py-3.5 w-full items-center justify-center inline-block">
                他チームからの連絡（仮置き）
              </a>
            </li>
            <li class="w-full">
              <a href="#" class="py-3.5 w-full items-center justify-center inline-block">
                他ユーザからの連絡（仮置き）
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
                  <li>
                    <a
                      href="#"
                      class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                    >
                      menu1-2
                    </a>
                  </li>
                  <li>
                    <a
                      href="#"
                      class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                    >
                      menu1-3
                    </a>
                  </li>
                </ul>
              </div>
            </li>
          </ul>
          <div class="pt-4 pb-1 px-8">
            <ul class="flex gap-y-2.5 flex-col">
              <li class="text-left flex items-center text-base">
                <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
                  person
                </span>
                nakoさんからの紹介 / mikaさん / Web開発（Elixir）
                <span class="text-brightGreen-300 font-bold pl-4 inline-block">1時間前</span>
              </li>
              <li class="text-left flex items-center text-base">
                <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
                  person
                </span>
                nakoさんからの紹介 / mikaさん / Web開発（Elixir）
                <span class="text-brightGreen-300 font-bold pl-4 inline-block">1時間前</span>
              </li>
              <li class="text-left flex items-center text-base">
                <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
                  person
                </span>
                nakoさんからの紹介 / mikaさん / Web開発（Elixir）
                <span class="text-brightGreen-300 font-bold pl-4 inline-block">1時間前</span>
              </li>
              <li class="text-left flex items-center text-base">
                <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
                  person
                </span>
                nakoさんからの紹介 / mikaさん / Web開発（Elixir）
                <span class="text-brightGray-300 font-bold pl-4 inline-block">8時間前</span>
              </li>
              <li class="text-left flex items-center text-base">
                <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
                  person
                </span>
                nakoさんからの紹介 / mikaさん / Web開発（Elixir）
                <span class="text-brightGray-300 font-bold pl-4 inline-block">1日前</span>
              </li>
            </ul>
          </div>
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
        </div>
      </div>
    </div>
    """
  end
end
