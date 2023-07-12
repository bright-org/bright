defmodule BrightWeb.IntriguingCardComponents do
  @moduledoc """
  Intriguing Card Components
  """
  use Phoenix.Component
  import BrightWeb.ProfileComponents

  # TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新

  @doc """
  Renders a Intriguing Card

  ## Examples
      <.intriguing_card />
  """
  def intriguing_card(assigns) do
    ~H"""
    <div>
    <h5>関わっているユーザー</h5>
    <div class="bg-white rounded-md mt-1">
      <div
        class="text-sm font-medium text-center text-brightGray-500"
      >
        <!-- tab1 -->
        <ul
          class="flex content-between border-b border-brightGray-200"
        >
          <li class="w-full">
            <a
              href="#"
              class="py-3.5 w-full items-center justify-center inline-block text-brightGreen-300 font-bold border-brightGreen-300 border-b-2"
              >気になる人</a>
          </li>
          <li class="w-full">
            <a
              href="#"
              class="py-3.5 w-full items-center justify-center inline-block"
              >チーム</a>
          </li>
          <li class="w-full">
            <a
              href="#"
              class="py-3.5 w-full items-center justify-center inline-block"
              >採用候補者</a>
          </li>
          <li class="flex items-center">
            <button
              type="button"
              id="dropmenu04"
              data-dropdown-offset-skidding="-130"
              data-dropdown-placement="bottom"
              data-dropdown-toggle="menu04"
              class="text-black rounded-full w-10 h-10 inline-flex items-center justify-center"
            >
              <span
                class="material-icons text-xs text-brightGreen-900"
                >more_vert</span>
            </button>
            <!-- 関わっているユーザー Dropdown menu -->
            <div
              id="menu04"
              class="z-10 hidden bg-white rounded-lg shadow-md min-w-[286px]"
            >
              <ul
                class="p-2 text-left text-base"
                aria-labelledby="dropmenu04"
              >
                <li>
                  <a
                    data-modal-target="defaultModal"
                    data-modal-toggle="defaultModal"
                    class="block px-4 py-3 hover:bg-brightGray-50 text-base hover:cursor-pointer"
                  >
                    カスタムグループを作る
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    class="block px-4 py-3 hover:bg-brightGray-50 text-base hover:cursor-pointer"
                    >カスタムグループの編集</a>
                </li>
                <li>
                  <a
                    href="#"
                    class="block px-4 py-3 hover:bg-brightGray-50 text-base hover:cursor-pointer"
                    >カスタムグループの削除</a>
                </li>
              </ul>
            </div>
          </li>
        </ul>

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

        <!-- 内容 -->
        <div class="pt-3 pb-1 px-6">
          <ul class="flex flex-wrap gap-y-1">
            <li
              class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2"
            >
              <a class="inline-flex items-center gap-x-6">
                <img
                  class="inline-block h-10 w-10 rounded-full"
                  src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
                />
                <div>
                  <p>nokichi</p>
                  <p class="text-brightGray-300">アプリエンジニア</p>
                </div>
              </a>
            </li>
            <li
              class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2"
            >
              <a class="inline-flex items-center gap-x-6">
                <img
                  class="inline-block h-10 w-10 rounded-full"
                  src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
                />
                <div>
                  <p>nokichi</p>
                  <p class="text-brightGray-300">アプリエンジニア</p>
                </div>
              </a>
            </li>
            <li
              class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2"
            >
              <a class="inline-flex items-center gap-x-6">
                <img
                  class="inline-block h-10 w-10 rounded-full"
                  src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
                />
                <div>
                  <p>nokichi</p>
                  <p class="text-brightGray-300">アプリエンジニア</p>
                </div>
              </a>
            </li>
            <li
              class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2"
            >
              <a class="inline-flex items-center gap-x-6">
                <img
                  class="inline-block h-10 w-10 rounded-full"
                  src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
                />
                <div>
                  <p>nokichi</p>
                  <p class="text-brightGray-300">アプリエンジニア</p>
                </div>
              </a>
            </li>
            <li
              class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2"
            >
              <a class="inline-flex items-center gap-x-6">
                <img
                  class="inline-block h-10 w-10 rounded-full"
                  src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
                />
                <div>
                  <p>nokichi</p>
                  <p class="text-brightGray-300">アプリエンジニア</p>
                </div>
              </a>
            </li>
          </ul>
        </div>

        <!--フッタ -->
        <div class="flex justify-center gap-x-14 pb-3">
          <button
            type="button"
            class="text-brightGray-200 bg-white px-3 py-1.5 inline-flex font-medium rounded-md text-sm items-center"
          >
            <span
              class="material-icons md-18 mr-2 text-brightGray-200"
              >chevron_left</span>
            前
          </button>
          <button
            type="button"
            class="text-brightGray-900 bg-white px-3 py-1.5 inline-flex font-medium rounded-md text-sm items-center"
          >
            次
            <span
              class="material-icons md-18 ml-2 text-brightGray-900"
              >chevron_right</span>
          </button>
        </div>
      </div>
    </div>
    </div>
    """
  end

  def intriguing_card_row(assigns) do
    """
    <div class="pt-3 pb-1 px-6">
      <ul class="flex flex-wrap gap-y-1">
        <%= for _ <- 1..5 do %>
          <.profile_small />
        <% end %>
      </ul>
    </div>
    """
  end
end
