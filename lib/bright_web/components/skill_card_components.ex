defmodule BrightWeb.SkillCardComponents do
  @moduledoc """
  Skill Card Components
  """
  use Phoenix.Component

  @doc """
  Renders a Skill Card

  ## Examples
      <.skill_card />
  """
  def skill_card(assigns) do
    ~H"""
    <div>
      <h5>保有スキル（ジェムをクリックすると成長グラフが見れます）</h5>
      <div class="bg-white rounded-md mt-1">
        <div class="text-sm font-medium text-center text-brightGray-200">
          <ul class="flex content-between border-b border-brightGray-50">
            <li class="w-full">
              <a
                href="#"
                class="py-3.5 w-full items-center justify-center inline-block text-brightGreen-300 font-bold border-brightGreen-300 border-b-2"
              >
                エンジニア
              </a>
            </li>
            <li class="w-full">
              <a href="#" class="py-3.5 w-full items-center justify-center inline-block">インフラ</a>
            </li>
            <li class="w-full">
              <a href="#" class="py-3.5 w-full items-center justify-center inline-block">デザイナー</a>
            </li>
            <li class="w-full">
              <a href="#" class="py-3.5 w-full items-center justify-center inline-block">
                マーケッター
              </a>
            </li>
          </ul>

          <div class="py-4 px-7 flex gap-y-3 flex-col">
            <div class="bg-brightGray-10 rounded-md text-base flex p-5 content-between">
              <p class="font-bold w-36 text-left text-sm">
                Webアプリ開発
              </p>
              <table class="table-fixed skill-table">
                <thead>
                  <tr>
                    <th class="w-[110px]"></th>
                    <th class="pl-8">クラス1</th>
                    <th class="pl-8">クラス2</th>
                    <th class="pl-8">クラス3</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Elixir</td>
                    <td>
                      <a href="/panels/my_skill_panel_id/graph/">
                        <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                          <img src="./images/common/icons/jemHigh.svg" class="mr-1" />ベテラン
                        </p>
                      </a>
                    </td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemMiddle.svg" class="mr-1" />平均
                      </p>
                    </td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemLow.svg" class="mr-1" />見習い
                      </p>
                    </td>
                  </tr>
                  <tr>
                    <td>PHP</td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemHigh.svg" class="mr-1" />ベテラン
                      </p>
                    </td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemMiddle.svg" class="mr-1" />平均
                      </p>
                    </td>
                    <td></td>
                  </tr>
                  <tr>
                    <td>Ruby</td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemLow.svg" class="mr-1" />見習い
                      </p>
                    </td>
                    <td></td>
                    <td></td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="bg-brightGray-10 rounded-md text-base flex p-5 content-between">
              <p class="font-bold w-36 text-left text-sm">
                Webアプリ開発
              </p>
              <table class="table-fixed skill-table">
                <thead>
                  <tr>
                    <th class="w-[110px]"></th>
                    <th class="pl-8">クラス1</th>
                    <th class="pl-8">クラス2</th>
                    <th class="pl-8">クラス3</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Elixir</td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemHigh.svg" class="mr-1" />ベテラン
                      </p>
                    </td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemMiddle.svg" class="mr-1" />平均
                      </p>
                    </td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemLow.svg" class="mr-1" />見習い
                      </p>
                    </td>
                  </tr>
                  <tr>
                    <td>PHP</td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemHigh.svg" class="mr-1" />ベテラン
                      </p>
                    </td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemMiddle.svg" class="mr-1" />平均
                      </p>
                    </td>
                    <td></td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="bg-brightGray-10 rounded-md text-base flex p-5 content-between">
              <p class="font-bold w-36 text-left text-sm">PM</p>
              <table class="table-fixed skill-table">
                <thead>
                  <tr>
                    <th class="w-[110px]"></th>
                    <th class="pl-8">クラス1</th>
                    <th class="pl-8">クラス2</th>
                    <th class="pl-8">クラス3</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td></td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemHigh.svg" class="mr-1" />ベテラン
                      </p>
                    </td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemMiddle.svg" class="mr-1" />平均
                      </p>
                    </td>
                    <td>
                      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
                        <img src="./images/common/icons/jemLow.svg" class="mr-1" />見習い
                      </p>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
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
