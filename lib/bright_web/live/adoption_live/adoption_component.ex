defmodule BrightWeb.AdoptionLive.AdoptionComponent do
  use BrightWeb, :live_component

  alias Bright.UserSearches

  def render(assigns) do
    ~H"""
    <div id="adoption_modal" class="hidden">
      <div class="bg-pureGray-600/90 fixed inset-0 transition-opacity z-[55]" />
      <div class="fixed inset-0 overflow-y-auto z-[60]">
        <main class="flex h-screen items-center justify-center w-screen" role="main">
          <section class="absolute bg-white px-10 py-8 shadow text-sm top-0 w-[1500px]">
            <h2 class="font-bold text-3xl">
              <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">採用依頼</span>
            </h2>

            <div class="flex mt-8">
            <!-- Start 採用候補者と依頼先 -->
              <div class="border-r border-r-brightGray-200 border-dashed mr-8 pr-8 w-[860px]">
                <div>
                  <h3 class="font-bold text-base">採用候補者</h3>
                  <.live_component
                    id="user_params"
                    prefix="adoption"
                    search={false}
                    module={BrightWeb.SearchLive.SearchResultsComponent}
                    current_user={@current_user}
                    result={@adoption_user}
                    skill_params={@skill_params}
                    stock_user_ids={[]}
                  />
                </div>

                <div class="mt-8">
                  <h3 class="font-bold text-base">面談調整依頼先<span class="font-normal">を追加</span></h3>

                    <div class="bg-white border border-brightGray-200 rounded-md mt-1">
                      <div
                        class="text-sm font-medium text-center text-brightGray-500"
                      >
                        <ul
                          class="flex content-between border-b border-brightGray-200"
                        >
                          <li class="w-60">
                            <a href="#" class="py-3.5 w-full items-center justify-center inline-block text-brightGreen-300 font-bold border-brightGreen-300 border-b-2">
                            所属チーム</a>
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
                            >
                            chevron_right</span>
                          </button>
                        </div>
                      </div>
                    </div>

                </div>
              </div><!-- End 採用候補者と依頼先 -->

            <!-- Start 採用調整内容 -->
              <div class="w-[493px]">
                <h3 class="font-bold text-xl">採用調整内容</h3>

                    <div class="bg-brightGray-10 mt-4 rounded-sm px-10 py-6">
                      <dl class="flex flex-wrap w-full">
                        <dt
                          class="font-bold w-[98px] flex items-center mb-10"
                        >
                          採用担当者
                        </dt>
                        <dd class="w-[280px] mb-10">
                          <div class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded border border-brightGray-100 bg-white w-full">
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
                                >
                                  close
                                </span>
                              </button>
                            </a>
                          </div>
                        </dd>

                        <dt
                          class="font-bold w-[98px] flex mt-16"
                        >
                          <label for="point" class="block pr-1">採用候補者の推しポイント・注意点</label>
                        </dt>
                        <dd class="w-[280px] mt-16">
                          <p>エンジニア領域だけでなく、インフラやデザイン、マーケティングなど幅広い領域の知識を持っていて劇ヤバイです。</p>
                        </dd>
                      </dl>
                    </div>

                  <div class="flex justify-end gap-x-4 mt-16">
                    <button
                      class="text-sm font-bold py-3 rounded text-white bg-base w-72"
                    >
                      採用を依頼する
                    </button>
                  </div>
              </div><!-- End 採用調整内容 -->

              <!-- close button -->
              <button
                class="absolute right-5 top-5 z-10"
                phx-click={JS.hide(to: "#adoption_modal")}
              >
                <span class="material-icons !text-3xl text-brightGray-900"
                  >close</span>
              </button>
            </div>
          </section>
        </main>
      </div>
    </div>
    """
  end

  def mount(socket) do
    socket
    |> assign(:search_results, [])
    |> assign(:adoption_user, [])
    |> assign(:skill_params, %{})
    |> then(&{:ok, &1})
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> then(&{:ok, &1})
  end

  def handle_event("open", %{"user" => user_id, "skill_params" => skill_params}, socket) do
    user = UserSearches.get_user_by_id_with_job_profile_and_skill_score(user_id, skill_params)
    IO.inspect(skill_params)

    skill_params =
      skill_params
      |> Enum.map(&(Enum.map(&1, fn {k, v} -> {String.to_atom(k), v} end) |> Enum.into(%{})))

    socket
    |> assign(:adoption_user, user)
    |> assign(:skill_params, skill_params)
    |> then(&{:noreply, &1})
  end
end
