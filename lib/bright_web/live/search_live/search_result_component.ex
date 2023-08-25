defmodule BrightWeb.SearchLive.SearchResultComponent do
  use BrightWeb, :live_component

  import BrightWeb.DisplayUserHelper, only: [encrypt_user_name: 1]

  def render(assigns) do
    ~H"""
    <ul class="mt-4">
      <%= for user <- @result do %>
      <!-- Start 検索結果 単体 -->
        <li class="border border-brightGray-200 flex h-64 mb-2 overflow-hidden p-2 rounded" :if={Enum.count(user.skill_class_scores) > 0}>
        <div class="bg-white w-[448px]">
          <ul class="search_result_tab border-b border-brightGray-200 flex">
            <li class="border-b-2 border-brightGreen-300 cursor-pointer min-w-fit overflow-hidden p-1.5 text-center whitespace-nowrap hover:bg-brightGray-50">Webアプリ開発 Elixir</li>
          </ul>

          <div id="search_result_contents">
            <!-- Start コンテンツ 1 -->
            <div class="relative">
              <p class="absolute left-0 ml-1 mt-1 top-0">クラス1</p>

              <div class="flex justify-between">
                <div class="-mt-4 ml-1 w-64">
                  <canvas id="radarChart" width="200" height="200"></canvas>
                </div>

                <div class="flex flex-wrap items-start ml-2 mt-6 w-52">
                  <div class="h-24 overflow-hidden w-20">
                    <canvas id="doughnutChart" width="80" height="80"></canvas>
                  </div>

                  <div class="h-24 overflow-hidden w-28">
                    <div class="h-20 ml-2 flex flex-wrap">
                      <p class="text-brightGreen-300 font-bold w-full flex mt-1 mb-1">
                        <img src="/images/common/icons/crown.svg" class="mr-2">
                        <span>ベテラン</span>
                      </p>

                      <div class="flex flex-col w-24 pl-6">
                        <div class="min-w-[4em] flex items-center">
                          <span class="h-4 w-4 rounded-full bg-brightGreen-600 inline-block mr-1"></span>
                          <span>68％</span>
                        </div>
                        <div class="min-w-[4em] flex items-center mt-1">
                          <span class="h-0 w-0 border-solid border-t-0 border-r-8 border-l-8 border-transparent border-b-[14px] border-b-brightGreen-300 inline-block mr-1"></span>
                          <span>11％</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <ul class="-mt-4 text-xs w-40">
                    <li>
                      <p>
                        <span class="inline-block w-28">エビデンスの登録率</span>
                        <span>30%</span>
                      </p>
                    </li>

                    <li>
                      <p>
                        <span class="inline-block w-28">教材の学習率</span>
                        <span>20%</span>
                      </p>
                    </li>

                    <li>
                      <p>
                        <span class="inline-block w-28">試験の合格率</span>
                        <span>60%</span>
                      </p>
                    </li>
                  </ul>
                </div>
              </div>
            </div><!-- End コンテンツ 1 -->
          </div>
        </div>

        <div class="border-l border-brightGray-200 border-dashed w-[500px] ml-2 px-2">
          <div class="flex">
            <div class="w-64">
              <p class="mb-2">
                <span>出勤可：</span>
                <span>月160h以上</span>
                <span>土日祝日不可</span>
              </p>

              <p class="mb-2">
                <span>リモート可：</span>
                <span>月160h以上</span>
                <span>土日祝日不可</span>
              </p>

              <p class="mb-4">
                <span>希望年収：</span>
                <span>1,000万円</span>
              </p>

              <p class="mb-2">
                <span>スキルの最終更新日：</span>
                <span>2023/05/10</span>
              </p>

              <p class="mb-2">
                <span>担当者ステータス：</span>
                <span><%= user.name %></span>
              </p>
            </div>

            <div class="border-l border-brightGray-200 border-dashed ml-2 pl-2 w-52">
              <button
                type="button"
                id="dropcheckmenu"
                data-dropdown-toggle="checkmenu"
                class="mb-2 justify-center text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200 hover:border-brightGreen-300 group w-52"
              >
              <span
                class="material-icons md-18 mr-1 text-brightGray-200 group-hover:text-brightGreen-300"
              >star</span>
              気になる
            </button>

            <button
              type="button"
              id="dropcheckmenu"
              data-dropdown-toggle="checkmenu"
              class="mb-2 justify-center text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200 hover:border-brightGreen-300 group w-52"
            >
              <span
                class="material-symbols-outlined md-18 mr-1 text-brightGray-200 group-hover:text-brightGreen-300"
              >inventory</span>
              候補者をストック
            </button>
              <% skill = List.first(@skill_params) %>
              <%= if skill == nil do%>
                <a class="bg-white block border border-solid border-brightGreen-300 font-bold mb-2 px-4 py-1 rounded select-none text-center text-brightGreen-300 w-52 opacity-50" disabled>
                  成長グラフへ
                </a>
              <% else %>
                <.link
                  class="bg-white block border border-solid border-brightGreen-300 cursor-pointer font-bold mb-2 px-4 py-1 rounded select-none text-center text-brightGreen-300 w-52 hover:opacity-50"
                  href={"/panels/#{skill.skill_panel}/anon/#{encrypt_user_name(user)}"}
                >
                  成長グラフへ
                </.link>
              <% end %>
              <.link
                class="bg-white block border border-solid border-brightGreen-300 cursor-pointer font-bold px-4 py-1 rounded select-none text-center text-brightGreen-300 w-52 hover:opacity-50"
                href={"/mypage/anon/#{encrypt_user_name(user)}"}
              >
              マイページへ
              </.link>
            </div>
          </div>

          <div class="flex justify-between mt-8">
            <a
              class="bg-brightGray-900 border border-solid border-brightGray-300 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-56 hover:opacity-50"
            >
              面談調整する
            </a>
            <a
              class="bg-brightGray-900 border border-solid border-brightGray-300 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-56 hover:opacity-50"
            >
              採用する
            </a>
          </div>
        </div>
      </li>
      <% end %>
    </ul>
    """
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> then(&{:ok, &1})
  end
end
