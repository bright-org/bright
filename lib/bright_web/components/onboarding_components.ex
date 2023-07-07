defmodule BrightWeb.OnbordingComponents do
  @moduledoc """
  Gem Components
  """
  use Phoenix.Component

  def select_career(assigns) do
    ~H"""
    <section class="bg-white p-8 min-h-[720px] relative rounded-lg">
      <h1 class="font-bold text-3xl">
        <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:align-[-5px] before:w-9">
          最初のスキルを選ぶ
        </span>
      </h1>

      <div class="flex flex-col mt-2 relative">
        <!-- やりたいことセクション ここから -->
        <section class="accordion mt-5 w-[1236px]">
          <div class="bg-brightGray-50 rounded w-full">
            <p class="bg-brightGray-900 cursor-pointer font-bold px-4 py-2 relative rounded select-none text-white transition-all hover:opacity-50 before:absolute before:block before:border-l-2 before:border-t-2 before:border-solid before:content-[''] before:h-3 before:-mt-2 before:rotate-225 before:right-4 before:top-1/2 before:w-3">
              やりたいことや興味・関心があることからスキルを選ぶ
            </p>

            <div class="hidden">
              <ul class="flex flex-wrap gap-4 justify-start p-4">
                <!-- やりたいこと ここから -->
                <li class="bg-white px-4 py-4 rounded select-none w-72 hover:opacity-50">
                  <a href="/onboardings/select_skill_panel" class="block">
                    <b class="block text-center">Webアプリを作りたい</b>
                    <div class="flex flex-wrap gap-2 justify-center mt-2 py-2">
                      <span class="bg-enginner-dark px-2 py-0.5 rounded-full text-white text-xs">
                        エンジニア
                      </span>
                      <span class="bg-infra-dark px-2 py-0.5 rounded-full text-white text-xs">
                        インフラ
                      </span>
                      <span class="bg-designer-dark px-2 py-0.5 rounded-full text-white text-xs">
                        デザイナー
                      </span>
                    </div>
                  </a>
                </li>
                <!-- やりたいこと ここまで（以降繰り返し） -->
                <li class="bg-white px-4 py-4 rounded select-none w-72 hover:opacity-50">
                  <a href="/onboardings/select_skill_panel" class="block">
                    <b class="block text-center">スマホアプリを作りたい</b>
                    <div class="flex flex-wrap gap-2 justify-center mt-2 py-2">
                      <span class="bg-enginner-dark px-2 py-0.5 rounded-full text-white text-xs">
                        エンジニア
                      </span>
                      <span class="bg-designer-dark px-2 py-0.5 rounded-full text-white text-xs">
                        デザイナー
                      </span>
                      <span class="bg-marketer-dark px-2 py-0.5 rounded-full text-white text-xs">
                        マーケッター
                      </span>
                    </div>
                  </a>
                </li>

                <li class="bg-white px-4 py-4 rounded select-none w-72 hover:opacity-50">
                  <a href="/onboardings/select_skill_panel" class="block">
                    <b class="block text-center">Webサイトを作りたい</b>
                    <div class="flex flex-wrap gap-2 justify-center mt-2 py-2">
                      <span class="bg-enginner-dark px-2 py-0.5 rounded-full text-white text-xs">
                        エンジニア
                      </span>
                      <span class="bg-designer-dark px-2 py-0.5 rounded-full text-white text-xs">
                        デザイナー
                      </span>
                    </div>
                  </a>
                </li>

                <li class="bg-white px-4 py-4 rounded select-none w-72 hover:opacity-50">
                  <a href="/onboardings/select_skill_panel" class="block">
                    <b class="block text-center">アプリやWebの広告に関りたい</b>
                    <div class="flex flex-wrap gap-2 justify-center mt-2 py-2">
                      <span class="bg-enginner-dark px-2 py-0.5 rounded-full text-white text-xs">
                        エンジニア
                      </span>
                      <span class="bg-infra-dark px-2 py-0.5 rounded-full text-white text-xs">
                        インフラ
                      </span>
                      <span class="bg-designer-dark px-2 py-0.5 rounded-full text-white text-xs">
                        デザイナー
                      </span>
                      <span class="bg-marketer-dark px-2 py-0.5 rounded-full text-white text-xs">
                        マーケッター
                      </span>
                    </div>
                  </a>
                </li>

                <li class="bg-white px-4 py-4 rounded select-none w-72 hover:opacity-50">
                  <a href="/onboardings/select_skill_panel" class="block">
                    <b class="block text-center">アプリやWebの広告に関りたい</b>
                    <div class="flex flex-wrap gap-2 justify-center mt-2 py-2">
                      <span class="bg-enginner-dark px-2 py-0.5 rounded-full text-white text-xs">
                        エンジニア
                      </span>
                      <span class="bg-designer-dark px-2 py-0.5 rounded-full text-white text-xs">
                        デザイナー
                      </span>
                    </div>
                  </a>
                </li>
              </ul>

              <form class="flex flex-wrap gap-4 justify-start p-4">
                <input
                  type="text"
                  placeholder="やりたいことに関連するキーワードを入れてください"
                  class="border border-solid border-black placeholder-brightGray-200 px-4 py-2 rounded-l w-[512px]"
                />
                <button class="bg-white border border-l-0 border-solid border-black font-bold -ml-4 px-4 py-2 rounded-r w-20 hover:opacity-50">
                  検索
                </button>
                <div class="w-full"><span class="px-4 text-brightGray-300">検索結果が表示されます。</span></div>
              </form>
            </div>
          </div>
        </section>
        <!-- やりたいことセクション ここまで -->

        <!-- なりたいジョブセクション ここから -->
        <section class="accordion flex mt-8 w-[1236px]">
          <div class="bg-brightGray-50 rounded w-full">
            <p class="bg-brightGray-900 cursor-pointer font-bold px-4 py-2 relative rounded select-none text-white hover:opacity-50 before:absolute before:block before:border-l-2 before:border-t-2 before:border-solid before:content-[''] before:h-3 before:-mt-2 before:rotate-225 before:right-4 before:top-1/2 before:w-3">
              現在のジョブ、または、なりたいジョブからスキルを選ぶ
            </p>

            <div class="hidden px-4 py-4">
              <!-- タブここから -->
              <aside id="select_job">
                <ul class="flex relative">
                  <li class="bg-enginner-dark select-none py-2 rounded-tl text-center text-white w-40">
                    エンジニア
                  </li>
                  <li class="bg-infra-dazzle cursor-pointer select-none py-2 text-center text-brightGray-200 w-40 hover:bg-infra-dark hover:text-white">
                    インフラ
                  </li>
                  <li class="bg-designer-dazzle cursor-pointer select-none py-2 text-center text-brightGray-200 w-40 hover:bg-designer-dark hover:text-white">
                    デザイナー
                  </li>
                  <li class="bg-marketer-dazzle cursor-pointer select-none py-2 rounded-tr text-center text-brightGray-200 w-40 hover:bg-marketer-dark hover:text-white">
                    マーケッター
                  </li>
                  <li>
                    <a
                      href="#"
                      class="absolute bg-brightGreen-300 block cursor-pointer font-bold select-none py-2 right-0 rounded text-center text-white -top-1.5 w-48 hover:opacity-50"
                    >
                      キャリアパスを見直す
                    </a>
                  </li>
                </ul>
              </aside>
              <!-- タブここまで -->

              <!-- ジョブセクションここから -->
              <section>
                <!-- ジョブエンジニアセクションここから -->
                <section class="bg-enginner-dazzle px-4 py-4">
                  <!-- ジョブ高度ここから -->
                  <div>
                    <p class="font-bold">高度</p>
                    <ul class="flex flex-wrap gap-4 mt-2">
                      <!-- ジョブここから -->

                      <!-- label for（2か所） と input id が連動しています-->
                      <li>
                        <label
                          class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_engineer_001"
                        >
                          プロダクトオーナー
                        </label>
                        <input type="checkbox" id="popup_engineer_001" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロダクトオーナー
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_engineer_001"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                      <!-- ジョブここまで (以降繰り返し) -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_engineer_002"
                        >
                          プロダクトマネージャー
                        </label>
                        <input type="checkbox" id="popup_engineer_002" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロダクトマネージャー
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_engineer_002"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_engineer_003"
                        >
                          プロジェクトマネージャー
                        </label>
                        <input type="checkbox" id="popup_engineer_003" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロジェクトマネージャー
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_engineer_003"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_engineer_004"
                        >
                          プロダクトマーケティングマネージャー
                        </label>
                        <input type="checkbox" id="popup_engineer_004" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロダクトマーケティングマネージャー
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_engineer_004"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                    </ul>
                  </div>
                  <!-- ジョブ高度ここまで -->

                  <!-- ジョブ応用ここから -->
                  <div class="mt-8">
                    <p class="font-bold">応用</p>
                    <ul class="flex flex-wrap gap-4 mt-2">
                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_engineer_005"
                        >
                          リードエンジニア
                        </label>
                        <input type="checkbox" id="popup_engineer_005" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              リードエンジニア
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_engineer_005"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                      <!-- ジョブここまで (以降繰り返し) -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_engineer_006"
                        >
                          レビュアー
                        </label>
                        <input type="checkbox" id="popup_engineer_006" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              レビュアー
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_engineer_006"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_engineer_007"
                        >
                          情シス
                        </label>
                        <input type="checkbox" id="popup_engineer_007" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              情シス
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_engineer_007"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_engineer_008"
                        >
                          テックリード
                        </label>
                        <input type="checkbox" id="popup_engineer_008" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              テックリード
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_engineer_008"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_engineer_009"
                        >
                          ITコンサルタント
                        </label>
                        <input type="checkbox" id="popup_engineer_009" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              ITコンサルタント
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_engineer_009"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_engineer_010"
                        >
                          ITデジタルマーケッター
                        </label>
                        <input type="checkbox" id="popup_engineer_010" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              ITデジタルマーケッター
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_engineer_010"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                    </ul>
                  </div>
                  <!-- ジョブ応用ここまで -->

                  <!-- ジョブ基本ここから -->
                  <div class="mt-8">
                    <p class="font-bold">基本</p>
                    <ul class="flex flex-wrap gap-4 mt-2">
                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_engineer_011"
                        >
                          PM
                        </label>
                        <input type="checkbox" id="popup_engineer_011" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              PM
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_engineer_011"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                      <!-- ジョブここまで (以降繰り返し) -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_engineer_012"
                        >
                          Webアプリ開発
                        </label>
                        <input type="checkbox" id="popup_engineer_012" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              Webアプリ開発
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-enginner-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_engineer_012"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                    </ul>
                  </div>
                  <!-- ジョブ基本ここまで -->
                </section>
                <!-- ジョブエンジニアセクションここまで -->

                <!-- ジョブインフラセクションここから -->
                <section class="bg-infra-dazzle px-4 py-4 hidden">
                  <!-- ジョブ高度ここから -->
                  <div>
                    <p class="font-bold">高度</p>
                    <ul class="flex flex-wrap gap-4 mt-2">
                      <!-- ジョブここから -->

                      <!-- label for（2か所） と input id が連動しています-->
                      <li>
                        <label
                          class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_infra_001"
                        >
                          プロダクトオーナー
                        </label>
                        <input type="checkbox" id="popup_infra_001" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロダクトオーナー
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_infra_001"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                      <!-- ジョブここまで (以降繰り返し) -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_infra_002"
                        >
                          プロダクトマネージャー
                        </label>
                        <input type="checkbox" id="popup_infra_002" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロダクトマネージャー
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_infra_002"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_infra_003"
                        >
                          プロジェクトマネージャー
                        </label>
                        <input type="checkbox" id="popup_infra_003" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロジェクトマネージャー
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_infra_003"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_infra_004"
                        >
                          プロダクトマーケティングマネージャー
                        </label>
                        <input type="checkbox" id="popup_infra_004" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロダクトマーケティングマネージャー
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_infra_004"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                    </ul>
                  </div>
                  <!-- ジョブ高度ここまで -->

                  <!-- ジョブ応用ここから -->
                  <div class="mt-8">
                    <p class="font-bold">応用</p>
                    <ul class="flex flex-wrap gap-4 mt-2">
                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_infra_005"
                        >
                          リードエンジニア
                        </label>
                        <input type="checkbox" id="popup_infra_005" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              リードエンジニア
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_infra_005"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                      <!-- ジョブここまで (以降繰り返し) -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_infra_006"
                        >
                          レビュアー
                        </label>
                        <input type="checkbox" id="popup_infra_006" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              レビュアー
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_infra_006"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_infra_007"
                        >
                          情シス
                        </label>
                        <input type="checkbox" id="popup_infra_007" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              情シス
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_infra_007"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_infra_008"
                        >
                          テックリード
                        </label>
                        <input type="checkbox" id="popup_infra_008" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              テックリード
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_infra_008"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_infra_009"
                        >
                          ITコンサルタント
                        </label>
                        <input type="checkbox" id="popup_infra_009" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              ITコンサルタント
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_infra_009"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_infra_010"
                        >
                          ITデジタルマーケッター
                        </label>
                        <input type="checkbox" id="popup_infra_010" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              ITデジタルマーケッター
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_infra_010"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                    </ul>
                  </div>
                  <!-- ジョブ応用ここまで -->

                  <!-- ジョブ基本ここから -->
                  <div class="mt-8">
                    <p class="font-bold">基本</p>
                    <ul class="flex flex-wrap gap-4 mt-2">
                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_infra_011"
                        >
                          PM
                        </label>
                        <input type="checkbox" id="popup_infra_011" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              PM
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_infra_011"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                      <!-- ジョブここまで (以降繰り返し) -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_infra_012"
                        >
                          Webアプリ開発
                        </label>
                        <input type="checkbox" id="popup_infra_012" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              Webアプリ開発
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-infra-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_infra_012"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                    </ul>
                  </div>
                  <!-- ジョブ基本ここまで -->
                </section>
                <!-- ジョブインフラセクションここまで -->





                <!-- ジョブデザイナーセクションここから -->
                <section class="bg-designer-dazzle px-4 py-4 hidden">
                  <!-- ジョブ高度ここから -->
                  <div>
                    <p class="font-bold">高度</p>
                    <ul class="flex flex-wrap gap-4 mt-2">
                      <!-- ジョブここから -->

                      <!-- label for（2か所） と input id が連動しています-->
                      <li>
                        <label
                          class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_designer_001"
                        >
                          プロダクトオーナー
                        </label>
                        <input type="checkbox" id="popup_designer_001" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロダクトオーナー
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_designer_001"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                      <!-- ジョブここまで (以降繰り返し) -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_designer_002"
                        >
                          プロダクトマネージャー
                        </label>
                        <input type="checkbox" id="popup_designer_002" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロダクトマネージャー
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_designer_002"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_designer_003"
                        >
                          プロジェクトマネージャー
                        </label>
                        <input type="checkbox" id="popup_designer_003" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロジェクトマネージャー
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_designer_003"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_designer_004"
                        >
                          プロダクトマーケティングマネージャー
                        </label>
                        <input type="checkbox" id="popup_designer_004" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロダクトマーケティングマネージャー
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_designer_004"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                    </ul>
                  </div>
                  <!-- ジョブ高度ここまで -->

                  <!-- ジョブ応用ここから -->
                  <div class="mt-8">
                    <p class="font-bold">応用</p>
                    <ul class="flex flex-wrap gap-4 mt-2">
                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_designer_005"
                        >
                          リードエンジニア
                        </label>
                        <input type="checkbox" id="popup_designer_005" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              リードエンジニア
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_designer_005"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                      <!-- ジョブここまで (以降繰り返し) -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_designer_006"
                        >
                          レビュアー
                        </label>
                        <input type="checkbox" id="popup_designer_006" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              レビュアー
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_designer_006"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_designer_007"
                        >
                          情シス
                        </label>
                        <input type="checkbox" id="popup_designer_007" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              情シス
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_designer_007"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_designer_008"
                        >
                          テックリード
                        </label>
                        <input type="checkbox" id="popup_designer_008" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              テックリード
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_designer_008"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_designer_009"
                        >
                          ITコンサルタント
                        </label>
                        <input type="checkbox" id="popup_designer_009" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              ITコンサルタント
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_designer_009"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_designer_010"
                        >
                          ITデジタルマーケッター
                        </label>
                        <input type="checkbox" id="popup_designer_010" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              ITデジタルマーケッター
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_designer_010"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                    </ul>
                  </div>
                  <!-- ジョブ応用ここまで -->

                  <!-- ジョブ基本ここから -->
                  <div class="mt-8">
                    <p class="font-bold">基本</p>
                    <ul class="flex flex-wrap gap-4 mt-2">
                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_designer_011"
                        >
                          PM
                        </label>
                        <input type="checkbox" id="popup_designer_011" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              PM
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_designer_011"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                      <!-- ジョブここまで (以降繰り返し) -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_designer_012"
                        >
                          Webアプリ開発
                        </label>
                        <input type="checkbox" id="popup_designer_012" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              Webアプリ開発
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-designer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_designer_012"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                    </ul>
                  </div>
                  <!-- ジョブ基本ここまで -->
                </section>
                <!-- ジョブデザイナーセクションここまで -->




                <!-- ジョブマーケッターセクションここから -->
                <section class="bg-marketer-dazzle px-4 py-4 hidden">
                  <!-- ジョブ高度ここから -->
                  <div>
                    <p class="font-bold">高度</p>
                    <ul class="flex flex-wrap gap-4 mt-2">
                      <!-- ジョブここから -->

                      <!-- label for（2か所） と input id が連動しています-->
                      <li>
                        <label
                          class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_marketer_001"
                        >
                          プロダクトオーナー
                        </label>
                        <input type="checkbox" id="popup_marketer_001" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロダクトオーナー
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_marketer_001"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                      <!-- ジョブここまで (以降繰り返し) -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_marketer_002"
                        >
                          プロダクトマネージャー
                        </label>
                        <input type="checkbox" id="popup_marketer_002" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロダクトマネージャー
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_marketer_002"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_marketer_003"
                        >
                          プロジェクトマネージャー
                        </label>
                        <input type="checkbox" id="popup_marketer_003" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロジェクトマネージャー
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_marketer_003"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_marketer_004"
                        >
                          プロダクトマーケティングマネージャー
                        </label>
                        <input type="checkbox" id="popup_marketer_004" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              プロダクトマーケティングマネージャー
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_marketer_004"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                    </ul>
                  </div>
                  <!-- ジョブ高度ここまで -->

                  <!-- ジョブ応用ここから -->
                  <div class="mt-8">
                    <p class="font-bold">応用</p>
                    <ul class="flex flex-wrap gap-4 mt-2">
                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_marketer_005"
                        >
                          リードエンジニア
                        </label>
                        <input type="checkbox" id="popup_marketer_005" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              リードエンジニア
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_marketer_005"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                      <!-- ジョブここまで (以降繰り返し) -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_marketer_006"
                        >
                          レビュアー
                        </label>
                        <input type="checkbox" id="popup_marketer_006" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              レビュアー
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_marketer_006"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_marketer_007"
                        >
                          情シス
                        </label>
                        <input type="checkbox" id="popup_marketer_007" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              情シス
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_marketer_007"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_marketer_008"
                        >
                          テックリード
                        </label>
                        <input type="checkbox" id="popup_marketer_008" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              テックリード
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_marketer_008"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_marketer_009"
                        >
                          ITコンサルタント
                        </label>
                        <input type="checkbox" id="popup_marketer_009" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              ITコンサルタント
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_marketer_009"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_marketer_010"
                        >
                          ITデジタルマーケッター
                        </label>
                        <input type="checkbox" id="popup_marketer_010" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              ITデジタルマーケッター
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_marketer_010"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                    </ul>
                  </div>
                  <!-- ジョブ応用ここまで -->

                  <!-- ジョブ基本ここから -->
                  <div class="mt-8">
                    <p class="font-bold">基本</p>
                    <ul class="flex flex-wrap gap-4 mt-2">
                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_marketer_011"
                        >
                          PM
                        </label>
                        <input type="checkbox" id="popup_marketer_011" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              PM
                            </b>
                            <p class="mt-4">高度なプログラミングスキルに加え、チーム開発、プロジェクト運営、インフラなどの幅広い知識が求められます。</p>
                            <div class="mt-2 text-sm">
                              <span>このキャリアパスになるにはいくつか条件があります。</span>
                              <ul class="mt-1">
                                <li>・アプリ開発のスキルパネルでベテラン以上が１つ</li>
                                <li>・分野別のスキルパネルで平均以上が２つ</li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_marketer_011"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                      <!-- ジョブここまで (以降繰り返し) -->

                      <!-- ジョブここから -->
                      <li>
                        <label
                          class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-2 rounded select-none text-white text-center hover:opacity-50 min-w-[220px] h-10 leading-10"
                          for="popup_marketer_012"
                        >
                          Webアプリ開発
                        </label>
                        <input type="checkbox" id="popup_marketer_012" class="peer hidden" />

                        <article class="border border-solid border-brightGray-200 bg-white fixed hidden left-1/2 max-w-xs px-6 py-4 rounded select-none top-1/2 -translate-x-1/2 -translate-y-1/2 z-2 peer-checked:block">
                          <div>
                            <b class="bg-bgGem bg-5 bg-left bg-no-repeat before:align-text-top before:content-[''] before:bg-contain before:h-6 before:inline-block before:w-6">
                              Webアプリ開発
                            </b>
                            <p class="mt-4">
                              Webアプリケーションを一人または、チームで開発します。開発言語での開発に加え、チーム開発、環境構築、初歩的な設計を行います。
                            </p>
                            <div class="mt-2 text-sm">
                              <span>次のキャリアパス候補</span>
                              <ul class="flex mt-1 gap-x-2">
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  PdM
                                </li>
                                <li class="before:bg-marketer-dark before:mr-1 before:rounded-full before:align-text-middle before:content-[''] before:h-3 before:inline-block before:w-3">
                                  Tech Lead
                                </li>
                              </ul>
                            </div>

                            <div class="flex flex-col mt-6">
                              <button class="bg-brightGray-900 border border-brightGray-900 border-solid mx-auto my-2 px-4 py-2 rounded select-none text-white w-56 hover:opacity-50">
                                <span>このキャリアパスを選ぶ</span>
                              </button>
                            </div>

                            <label
                              for="popup_marketer_012"
                              class="absolute block top-2 right-2 hover:opacity-50"
                            >
                              <span class="relative block cursor-pointer h-5 rounded-full w-5 before:absolute before:block before:border-t-2 before:border-brightGray-900 before:content-[''] before:h-0 before:left-1/2 before:rotate-[45deg] before:top-1/2 before:translate-x-[-50%] before:translate-y-[-50%] before:w-3 after:absolute after:block after:border-t-2 after:border-brightGray-900 after:content-[''] after:h-0 after:left-1/2 after:rotate-[-45deg] after:top-1/2 after:translate-x-[-50%] after:translate-y-[-50%] after:w-3 hover:bg-brightGray-900 hover:before:border-white hover:after:border-white">
                              </span>
                            </label>
                          </div>
                        </article>
                      </li>
                      <!-- ジョブここまで -->
                    </ul>
                  </div>
                  <!-- ジョブ基本ここまで -->
                </section>
                <!-- ジョブマーケティングセクション ここまで -->
              </section>
              <!-- ジョブセクション ここまで -->
            </div>
          </div>
        </section>
        <!-- なりたいジョブセクション ここまで -->
      </div>

      <p class="mt-8">
        <a href="#" class="text-link text-xs underline">採用担当、人事、営業の方はこちら（自分のスキルを登録しません）</a>
      </p>
    </section>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.0/jquery.min.js">
    </script>
    <script src="https://code.jquery.com/ui/1.10.3/jquery-ui.min.js">
    </script>
    <script>
      // Accordion
      $(function(){
      $('.accordion').children("div").children("p").on("click", function(){
      $(this).toggleClass('active');
      $(this).next('div.hidden').slideToggle();
      // Open時は左下・右下の角丸をやめる&矢印の向きを変える
      if($(this).hasClass("active")){
        $(this).addClass("rounded-bl-none");
        $(this).addClass("rounded-br-none");
        $(this).removeClass("before:-mt-2");
        $(this).removeClass("before:rotate-225");
        $(this).addClass("before:-mt-0.5");
        $(this).addClass("before:rotate-45");
      } else {
        $(this).removeClass("rounded-bl-none");
        $(this).removeClass("rounded-br-none");
        $(this).removeClass("before:-mt-0.5");
        $(this).removeClass("before:rotate-45");
        $(this).addClass("before:-mt-2");
        $(this).addClass("before:rotate-225");
      }
      });
      });
      // Tab
      $(function(){
      let tab = $("#select_job").children("ul").children("li");
      tab.on("click",function(){
      let index = $(this).index();
      // タブの色を変える ここから
      tab.removeClass("bg-enginner-dark");
      tab.removeClass("bg-enginner-dazzle");
      tab.removeClass("hover:bg-enginner-dark");
      tab.removeClass("bg-infra-dark");
      tab.removeClass("bg-infra-dazzle");
      tab.removeClass("hover:bg-infra-dark");
      tab.removeClass("bg-designer-dark");
      tab.removeClass("bg-designer-dazzle");
      tab.removeClass("hover:bg-designer-dark");
      tab.removeClass("bg-marketer-dark");
      tab.removeClass("bg-marketer-dazzle");
      tab.removeClass("hover:bg-marketer-dark");
      tab.removeClass("text-white");
      tab.addClass("cursor-pointer");
      tab.addClass("text-brightGray-200");
      tab.addClass("hover:text-white");
      tab.eq(index).removeClass("cursor-pointer");
      tab.eq(index).removeClass("text-brightGray-200");
      tab.eq(index).removeClass("hover:text-white");
      tab.eq(index).addClass("text-white");
      console.log(index);
      if(index == 0){
        tab.eq(0).addClass("bg-enginner-dark");
        tab.eq(1).addClass("bg-infra-dazzle");
        tab.eq(1).addClass("hover:bg-infra-dark");
        tab.eq(2).addClass("bg-designer-dazzle");
        tab.eq(2).addClass("hover:bg-designer-dark");
        tab.eq(3).addClass("bg-marketer-dazzle");
        tab.eq(3).addClass("hover:bg-marketer-dark");
      } else if(index == 1){
        tab.eq(0).addClass("bg-enginner-dazzle");
        tab.eq(0).addClass("hover:bg-enginner-dark");
        tab.eq(1).addClass("bg-infra-dark");
        tab.eq(2).addClass("bg-designer-dazzle");
        tab.eq(2).addClass("hover:bg-designer-dark");
        tab.eq(3).addClass("bg-marketer-dazzle");
        tab.eq(3).addClass("hover:bg-marketer-dark");
      } else if(index == 2){
        tab.eq(0).addClass("bg-enginner-dazzle");
        tab.eq(0).addClass("hover:bg-enginner-dark");
        tab.eq(1).addClass("bg-infra-dazzle");
        tab.eq(1).addClass("hover:bg-infra-dark");
        tab.eq(2).addClass("bg-designer-dark");
        tab.eq(3).addClass("bg-marketer-dazzle");
        tab.eq(3).addClass("hover:bg-marketer-dark");
      } else if(index == 3){
        tab.eq(0).addClass("bg-enginner-dazzle");
        tab.eq(0).addClass("hover:bg-enginner-dark");
        tab.eq(1).addClass("bg-infra-dazzle");
        tab.eq(1).addClass("hover:bg-infra-dark");
        tab.eq(2).addClass("hover:bg-designer-dark");
        tab.eq(2).addClass("bg-designer-dazzle");
        tab.eq(3).addClass("bg-marketer-dark");
      } else {
        tab.addClass("bg-brightGray-900");
        tab.addClass("hover:opacity-50");
      }
      // タブの色を変える ここまで

      // クリックされたタブと連動してジョブセクションの表示が切り替わる ここから
      let section = $("#select_job").next("section").children("section");
      section.addClass("hidden");
      section.eq(index).removeClass("hidden");
      // クリックされたタブと連動してジョブセクションの表示が切り替わる ここまで
      });
      });
      // Window Drug
      $(function(){
      $("input[type='checkbox']").next("article").draggable({ containment: "#section" });
      });
    </script>
    """
  end

  def select_skill_panel(assigns) do
    ~H"""
    <section class="bg-white p-8 min-h-[720px] relative rounded-lg">
      <h1 class="font-bold text-3xl">
        <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
          最初のスキルを選ぶ
        </span>
      </h1>

      <div class="flex flex-col mt-4">
        <!-- スキルセクション ここから -->
        <section>
          <!-- スキルエンジニアセクション ここから -->
          <section class="bg-enginner-dazzle mt-4 px-4 py-4 w-[1040px]">
            <p class="font-bold">エンジニア向けのスキル</p>
            <ul class="flex flex-wrap mt-2 gap-4">
              <!-- スキル ここから -->
              <li>
                <button class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  Elixir
                </button>
              </li>
              <!-- スキル ここまで (以降繰り返し) -->
              <li>
                <button class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  Java
                </button>
              </li>

              <li>
                <button class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  PHP
                </button>
              </li>

              <li>
                <button class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  Python
                </button>
              </li>

              <li>
                <button class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  Puby
                </button>
              </li>

              <li>
                <button class="bg-enginner-dark block border border-solid border-enginner-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  Java Script
                </button>
              </li>
            </ul>
          </section>
          <!-- スキルエンジニアセクション ここまで -->

          <!-- スキルインフラセクション ここから -->
          <section class="bg-infra-dazzle mt-4 px-4 py-4 w-[1040px]">
            <p class="font-bold">インフラ向けのスキル</p>
            <ul class="flex flex-wrap mt-2 gap-4">
              <!-- スキル ここから -->
              <li>
                <button class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  SQL
                </button>
              </li>
              <!-- スキル ここまで (以降繰り返し) -->
              <li>
                <button class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  DB
                </button>
              </li>

              <li>
                <button class="bg-infra-dark block border border-solid border-infra-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  ネットワーク
                </button>
              </li>
            </ul>
          </section>
          <!-- スキルインフラセクション ここまで -->

          <!-- スキルデザイナーセクション ここから -->
          <section class="bg-designer-dazzle mt-4 px-4 py-4 w-[1040px]">
            <p class="font-bold">デザイナー向けのスキル</p>
            <ul class="flex flex-wrap mt-2 gap-4">
              <!-- スキル ここから -->
              <li>
                <button class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  Webデザイン
                </button>
              </li>
              <!-- スキル ここまで (以降繰り返し) -->
              <li>
                <button class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  HTML/CSS
                </button>
              </li>

              <li>
                <button class="bg-designer-dark block border border-solid border-designer-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  Figma
                </button>
              </li>
            </ul>
          </section>
          <!-- スキルデザイナーセクション ここまで -->

          <!-- スキルマーケッターセクション ここから -->
          <section class="bg-marketer-dazzle mt-4 px-4 py-4 w-[1040px]">
            <p class="font-bold">マーケッター向けのスキル</p>
            <ul class="flex flex-wrap mt-2 gap-4">
              <!-- スキル ここから -->
              <li>
                <button class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  GA4
                </button>
              </li>
              <!-- スキル ここまで (以降繰り返し) -->
              <li>
                <button class="bg-marketer-dark block border border-solid border-marketer-dark cursor-pointer font-bold px-4 py-2 rounded select-none text-white text-center w-60 hover:opacity-50">
                  SEO
                </button>
              </li>
            </ul>
          </section>
          <!-- スキルマーケッターセクション ここまで -->
        </section>
        <!-- スキルセクション ここまで -->
      </div>

      <p class="mt-8">
        <button
          onclick="location.href='/onboardings'"
          class="bg-white block border border-solid border-black font-bold mt-4 mx-auto px-4 py-2 rounded select-none text-black w-40 hover:opacity-50"
        >
          戻る
        </button>
      </p>
    </section>
    """
  end
end
