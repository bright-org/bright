defmodule BrightWeb.ProfileComponents do
  @moduledoc """
  Profile Components
  """
  use Phoenix.Component

  @doc """
  Renders a Profile

  ## Examples
      <.profile title="リードプログラマー" user_name="piacere" detail="高校・大学と野球部に入っていました。チームで開発を行うような仕事が得意です。メインで使っている言語はJavaで中規模～大規模のシステム開発を受け持っています。最近Elixirを学び始め、Elixirで仕事ができると嬉しいです。" icon_file_path="/images/sample/sample-image.png" display_excellent_person display_anxious_person display_return_to_yourself display_stock_candidates_for_employment display_adopt display_sns/>
  """
  attr :user_name, :string, default: ""
  attr :title, :string, default: ""
  attr :detail, :string, default: ""
  attr :icon_file_path, :string, default: ""
  attr :display_excellent_person, :boolean, default: false
  attr :display_anxious_person, :boolean, default: false
  attr :display_return_to_yourself, :boolean, default: false
  attr :display_stock_candidates_for_employment, :boolean, default: false
  attr :display_adopt, :boolean, default: false
  attr :display_sns, :boolean, default: false

  def profile(assigns) do
    assigns = assign(assigns, :icon_style, "background-image: url('#{assigns.icon_file_path}');")

    ~H"""
    <div class="w-[850px] pt-4">
      <div class="flex">
        <div class="bg-test bg-contain h-20 w-20 mr-5" style={@icon_style}></div>
        <div class="flex-1">
          <div class="flex justify-between pb-2 items-end">
            <div class="text-2xl font-bold"><%= assigns.user_name %></div>
            <div class="flex gap-x-3">
              <%= if assigns.display_excellent_person do %>
                <button
                  type="button"
                  class="text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGreen-300"
                >
                  <span class="material-icons md-18 mr-1 text-brightGreen-300">share</span> 優秀な人として紹介
                </button>
              <% end %>

              <%= if assigns.display_anxious_person do %>
                <button
                  type="button"
                  id="dropcheckmenu"
                  data-dropdown-toggle="checkmenu"
                  class="text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
                >
                  <span class="material-icons md-18 mr-1 text-brightGray-200">star</span> 気になる
                </button>
                <!-- 気になるDropdown menu -->
                <div id="checkmenu" class="z-10 hidden bg-white rounded-lg shadow min-w-[286px]">
                  <ul class="p-2 text-left text-base" aria-labelledby="dropcheckmenu">
                    <li>
                      <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">気になるリスト</a>
                    </li>
                    <li>
                      <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">メンバー候補</a>
                    </li>
                    <li>
                      <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">
                        java開発者リスト
                      </a>
                    </li>
                    <li>
                      <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">
                        Python開発者リスト
                      </a>
                    </li>
                    <li>
                      <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">
                        ジュニアエンジニア
                      </a>
                    </li>
                    <li>
                      <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">
                        シニアエンジニア
                      </a>
                    </li>
                    <li class="px-4 py-3 hover:bg-brightGray-50 flex justify-center gap-x-2">
                      <input
                        type="text"
                        placeholder="リスト名を入力"
                        class="px-2 py-1 border border-brightGray-900 rounded-sm flex-1 w-full text-base w-[220px]"
                      />
                      <button class="text-sm font-bold px-4 py-1 rounded text-white bg-base">
                        新規作成
                      </button>
                    </li>
                  </ul>
                </div>
              <% end %>

              <%= if assigns.display_return_to_yourself do %>
                <button
                  type="button"
                  class="text-brightGreen-300 bg-white px-2 py-1 inline-flex rounded-md text-sm items-center border border-brightGreen-300 font-bold"
                >
                  自分に戻す
                </button>
              <% end %>

              <%= if assigns.display_stock_candidates_for_employment do %>
                <button
                  type="button"
                  class="text-brightGreen-300 bg-white px-2 py-1 inline-flex rounded-md text-sm items-center border border-brightGreen-300 font-bold"
                >
                  採用候補者としてストック
                </button>
              <% end %>

              <%= if assigns.display_adopt do %>
                <button
                  type="button"
                  class="text-brightGreen-300 bg-white px-2 py-1 inline-flex rounded-md text-sm items-center border border-brightGreen-300 font-bold"
                >
                  採用する
                </button>
              <% end %>

              <button
                type="button"
                class="text-brightGreen-300 bg-white px-2 py-1 inline-flex rounded-md text-sm items-center border border-brightGreen-300 font-bold"
              >
                採用の調整
              </button>
            </div>
          </div>

          <div class="flex justify-between pt-3 border-brightGray-100 border-t">
            <div class="text-2xl"><%= assigns.title %></div>
            <%= if assigns.display_sns do %>
              <div class="flex gap-x-6 mr-2">
                <button type="button">
                  <img src="/images/common/twitter.svg" width="26px" />
                </button>
                <button type="button">
                  <img src="/images/common/github.svg" width="26px" />
                </button>
                <button type="button">
                  <img src="/images/common/facebook.svg" width="26px" />
                </button>
              </div>
            <% end %>
          </div>
        </div>
      </div>
      <div class="pt-5">
        <%= assigns.detail %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a Profile small

  ## Examples
      <.profile_snall/>
  """
  def profile_small(assigns) do
    ~H"""
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2">
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
    """
  end
end
