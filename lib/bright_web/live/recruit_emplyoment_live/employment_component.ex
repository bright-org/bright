defmodule BrightWeb.RecruitEmploymentLive.EmploymentComponent do
  use BrightWeb, :live_component

  # import BrightWeb.ProfileComponents, only: [profile_small: 1]
  # import Bright.UserProfiles, only: [icon_url: 1]

  def render(assigns) do
    ~H"""
    <div id="employment_modal">
      <div class="bg-pureGray-600/90 transition-opacity z-[55]" />
      <div class="overflow-y-auto z-[60]">
        <main class="flex items-center justify-center" role="main">
          <section class="bg-white px-10 py-8 shadow text-sm">
            <h2 class="font-bold text-3xl">
              <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">ジョイン先決定</span>
            </h2>

            <div class="flex mt-8">
            <!-- Start 採用候補者と依頼先 -->
              <div class="border-r border-r-brightGray-200 border-dashed mr-8 pr-8 w-[928px]">
                <div>
                  <h3 class="font-bold text-base">採用候補者</h3>

                  <ul class="mt-4">
                    <!-- Start 検索結果 単体 -->
                    <li class="border border-brightGray-200 flex h-64 mb-2 overflow-hidden p-2 rounded">
                      <div class="bg-white w-[448px]">
                        <div class="flex">
                          <div class="overflow-hidden">
                            <ul class="search_result_tab border-b border-brightGray-200 flex w-[99999px]">
                              <li class="w-[200px] border-b-2 border-brightGreen-300 cursor-pointer min-w-fit overflow-hidden p-1.5 text-center whitespace-nowrap hover:bg-brightGray-50">Webアプリ開発 Elixir</li>
                            </ul>
                          </div>

                          <div class="border-b border-brightGray-200 flex">
                            <button type="button" class="px-1 border-l border-brightGray-50">
                              <span class="w-0 h-0 border-solid border-l-0 border-r-[10px] border-r-brightGray-300 border-t-[6px] border-t-transparent border-b-[6px] border-b-transparent inline-block"></span>
                            </button>
                            <button type="button" class="px-1 border-l border-brightGray-50">
                              <span class="w-0 h-0 border-solid border-r-0 border-l-[10px] border-l-brightGray-300 border-t-[6px] border-t-transparent border-b-[6px] border-b-transparent inline-block"></span>
                            </button>
                          </div>
                        </div>

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
                                      <img src="./images/common/icons/crown.svg" class="mr-2">
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

                      <div class="border-l border-brightGray-200 border-dashed w-[422px] ml-4 px-4 overflow-hidden">
                        <div class="flex">
                          <div class="w-full">
                            <p class="mb-2">
                              <span class="">出勤可：</span>
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

                            <p class="border-t border-brightGray-200 mb-2 mt-2 pt-4">
                              <span>スキルの最終更新日：</span>
                              <span>2023/05/10</span>
                            </p>

                            <p class="mb-2">
                              <span>担当者ステータス：</span>
                              <span>－</span>
                            </p>

                            <div class="flex justify-between mt-8">
                              <a class="bg-white block border border-solid border-brightGreen-300 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-brightGreen-300 w-44 hover:opacity-50">成長グラフを開く</a>

                              <a class="bg-white block border border-solid border-brightGreen-300 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-brightGreen-300 w-44 hover:opacity-50">スキルパネルを開く</a>
                            </div>
                          </div>
                        </div>
                      </div>
                    </li><!-- End 検索結果 -->
                  </ul>
                </div>

                <div class="mt-8">
                  <h3 class="font-bold text-base">ジョイン先チーム管理者<span class="font-normal">を追加</span></h3>
                    <div class="bg-white border border-brightGray-200 rounded-md mt-1">
                      <div class="text-sm font-medium text-center text-brightGray-500">
                        <ul id="team_tab_menu_1" class="flex content-between border-b border-brightGray-200">
                          <li class="w-60">
                            <a href="#" class="py-3.5 w-full items-center justify-center inline-block text-brightGreen-300 font-bold border-brightGreen-300 border-b-2">
                              所属チーム
                            </a>
                          </li>
                          <li class="w-60">
                            <a href="#" class="py-3.5 w-full items-center justify-center inline-block">
                              支援先チーム
                            </a>
                          </li>
                        </ul>

                        <div class="flex border-b border-brightGray-50">
                          <div class="overflow-hidden">
                            <ul
                              id="team_tab_menu_2"
                              class="overflow-hidden flex text-base !text-sm w-full"
                            >
                              <li
                                class="py-2 w-[200px] border-r border-brightGray-50"
                              >
                                開発一部人材チーム
                              </li>
                              <li
                                class="py-2 w-[200px] border-r border-brightGray-50 bg-brightGreen-50"
                              >
                                開発二部人材チーム
                              </li>
                              <li
                                class="py-2 w-[200px] border-r border-brightGray-50"
                              >
                                デザイン人材チーム
                              </li>
                              <li
                                class="py-2 w-[200px] border-r border-brightGray-50"
                              >
                                デーータ分析チーム１
                              </li>
                              <li
                                class="py-2 w-[200px] border-r border-brightGray-50"
                              >
                                デーータ分析チーム２
                              </li>
                            </ul>
                          </div>
                          <button class="px-1 border-l border-brightGray-50">
                            <span
                              class="w-0 h-0 border-solid border-l-0 border-r-[10px] border-r-brightGray-300 border-t-[6px] border-t-transparent border-b-[6px] border-b-transparent inline-block"
                            ></span>
                          </button>
                          <button class="px-1 border-l border-brightGray-50">
                            <span
                              class="w-0 h-0 border-solid border-r-0 border-l-[10px] border-l-brightGray-300 border-t-[6px] border-t-transparent border-b-[6px] border-b-transparent inline-block"
                            ></span>
                          </button>
                        </div>

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
                </div><!-- End 採用候補者と依頼先 -->

                <!-- Start ジョイン先チーム調整内容 -->
                <div class="w-[493px]">
                  <h3 class="font-bold text-xl">ジョイン先チーム調整内容</h3>
                      <div class="bg-brightGray-10 mt-4 rounded-sm px-10 py-6">
                        <dl class="flex flex-wrap w-full">
                          <dt class="font-bold w-[98px] mb-10">ジョイン<br>先チーム<br>管理者</dt>
                          <dd class="w-[280px]">
                            <ul class="flex flex-wrap gap-y-1">
                              <li
                                class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded border border-brightGray-100 bg-white w-full"
                              >
                                <a
                                  class="inline-flex items-center gap-x-6 w-full"
                                >
                                  <img
                                    class="inline-block h-10 w-10 rounded-full"
                                    src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
                                  />
                                  <div class="flex-auto">
                                    <p>nokichi</p>
                                    <p class="text-brightGray-300">
                                      アプリエンジニア
                                    </p>
                                  </div>
                                  <button class="mx-4">
                                    <span
                                      class="material-icons text-white !text-sm bg-base rounded-full !inline-flex w-4 h-4 !items-center !justify-center"
                                      >close</span>
                                  </button>
                                </a>
                              </li>
                              <li
                                class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded border border-brightGray-100 bg-white w-full"
                              >
                                <a
                                  class="inline-flex items-center gap-x-6 w-full"
                                >
                                  <img
                                    class="inline-block h-10 w-10 rounded-full"
                                    src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
                                  />
                                  <div class="flex-auto">
                                    <p>nokichi</p>
                                    <p class="text-brightGray-300">
                                      アプリエンジニア
                                    </p>
                                  </div>
                                  <button class="mx-4">
                                    <span
                                      class="material-icons text-white !text-sm bg-base rounded-full !inline-flex w-4 h-4 !items-center !justify-center"
                                      >close</span>
                                  </button>
                                </a>
                              </li>
                              <li
                                class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded border border-brightGray-100 bg-white w-full"
                              >
                                <a
                                  class="inline-flex items-center gap-x-6 w-full"
                                >
                                  <img
                                    class="inline-block h-10 w-10 rounded-full"
                                    src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
                                  />
                                  <div class="flex-auto">
                                    <p>nokichi</p>
                                    <p class="text-brightGray-300">
                                      アプリエンジニア
                                    </p>
                                  </div>
                                  <button class="mx-4">
                                    <span
                                      class="material-icons text-white !text-sm bg-base rounded-full !inline-flex w-4 h-4 !items-center !justify-center"
                                      >close</span>
                                  </button>
                                </a>
                              </li>
                            </ul>
                          </dd>

                          <dt
                            class="font-bold w-[98px] flex mt-16"
                          >
                            <label for="point" class="block pr-1">稼働按分・工数の扱いに関するメモ・注意点</label>
                          </dt>
                          <dd class="w-[280px] mt-16">
                            <textarea
                              id="point"
                              name="point"
                              placeholder="新しいチーム名を入力してください"
                              rows="5"
                              cols="30"
                              class="px-5 py-2 border border-brightGray-100 rounded-sm flex-1 w-full"
                            >エンジニア領域だけでなく、インフラやデザイン、マーケティングなど幅広い領域の知識を持っていて劇ヤバイです。</textarea>
                          </dd>
                        </dl>
                      </div>

                    <div class="flex justify-end gap-x-4 mt-16">
                      <button
                        class="text-sm font-bold py-3 rounded text-white bg-base w-72"
                      >
                        候補者のチーム招待を依頼する
                      </button>
                    </div>
                </div><!-- End ジョイン先チーム調整内容 -->

              </div>
            </section>
          </main>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign(:no_answer_error, "")
    |> then(&{:ok, &1})
  end
end
