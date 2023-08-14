defmodule BrightWeb.SkillPanelLive.SkillsComponents do
  use Phoenix.Component

  def compares(assigns) do
    ~H"""
    <div class="flex mt-4 items-center">
      <.compare_timeline />
      <% # TODO: 仮UI コンポーネント完成後に削除 %>
      <div class="flex gap-x-4">
        <button
          class="border border-brightGray-200 rounded-md py-1.5 pl-3 flex items-center"
          type="button"
          phx-click="demo_compare_user"
        >
          <span class="min-w-[6em]">個人と比較</span>
          <span
            class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-7px] before:bg-brightGray-200 before:w-[1px] before:h-[38px]">add</span>
        </button>
        <% # TODO: コンポーネント完成後にifを除去して表示 %>
        <.compare_individual :if={false} current_user={@current_user} />
        <% # TODO: α版後にifを除去して表示 %>
        <.compare_team :if={false} current_user={@current_user} />
        <% # TODO: α版後にifを除去して表示 %>
        <.compare_custom_group :if={false} />
      </div>
    </div>
    """
  end

  def compare_timeline(assigns) do
    ~H"""
      <div class="w-[566px] mr-10">
        <div class="flex">
          <div class="flex justify-center items-center ml-1 mr-3">
            <button
              class="w-6 h-8 bg-brightGray-900 flex justify-center items-center rounded"
            >
              <span class="material-icons text-white !text-3xl"
                >arrow_left</span>
            </button>
          </div>
          <div
            class="bg-brightGray-50 h-[44px] rounded-full w-[500px] my-5 flex justify-around items-center relative"
          >
            <div
              class="h-[80px] w-[80px] flex justify-center items-center"
            >
              <button
                class="h-[56px] w-[56px] border border-brightGray-50 text-brightGray-500 font-bold rounded-full bg-white text-xs flex justify-center items-center"
              >
                2022.12
              </button>
            </div>
            <div
              class="h-[80px] w-[80px] flex justify-center items-center"
            >
              <button
                class="h-[56px] w-[56px] border border-brightGray-50 text-brightGray-500 font-bold rounded-full bg-white text-xs flex justify-center items-center"
              >
                2023.3
              </button>
            </div>
            <div class="h-[80px] w-[80px]">
              <button
                class="h-[80px] w-[80px] rounded-full bg-brightGreen-50 border-white border-8 shadow text-brightGreen-600 font-bold text-xs flex justify-center items-center flex-col"
              >
                <span class="material-icons !text-[22px] !font-bold">check</span>
                2022.6
              </button>
            </div>

            <div
              class="h-[80px] w-[80px] flex justify-center items-center"
            >
              <button
                class="h-[56px] w-[56px] border border-brightGray-50 text-brightGray-500 font-bold rounded-full bg-white text-xs flex justify-center items-center"
              >
                2023.9
              </button>
            </div>
            <div
              class="h-[80px] w-[80px] flex justify-center items-center"
            >
              <button
                class="h-[56px] w-[56px] border border-brightGray-50 text-brightGray-500 font-bold rounded-full bg-white text-xs flex justify-center items-center"
              >
                2023.12
              </button>
            </div>
            <div
              class="h-[80px] w-[80px] flex justify-center items-center absolute right-[58px]"
            >
              <button
                class="h-[38px] w-[38px] border border-brightGray-50 text-attention-900 font-bold rounded-full bg-white text-xs flex justify-center items-center"
              >
                現在
              </button>
            </div>
          </div>
          <div class="flex justify-center items-center ml-2">
            <button
              class="w-6 h-8 bg-brightGray-300 flex justify-center items-center rounded"
            >
              <span class="material-icons text-white !text-3xl"
                >arrow_right</span>
            </button>
          </div>
        </div>
      </div>
    """
  end

  def compare_individual(assigns) do
    ~H"""
    <button
      id="addCompareDropdownButton"
      data-dropdown-toggle="addCompareDropdown"
      data-dropdown-offset-skidding="300"
      data-dropdown-placement="bottom"
      class="border border-brightGray-200 rounded-md py-1.5 pl-3 flex items-center"
      type="button"
    >
      <span class="min-w-[6em]">個人と比較</span>
      <span
        class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-7px] before:bg-brightGray-200 before:w-[1px] before:h-[38px]"
        >add</span>
    </button>
    <!-- 個人と比較Donwdrop -->
    <div
      class="bg-white rounded-md mt-1 w-[750px] bottom border-brightGray-100 border shadow-md hidden"
      id="addCompareDropdown"
    >
      <.live_component
        id="intriguing_card_compare"
        module={BrightWeb.CardLive.IntriguingCardComponent}
        current_user={@current_user}
        display_menu={false}
      />
    </div>
    """
  end

  def compare_team(assigns) do
    ~H"""
    <button
      id="compareAllDropdownButton"
      data-dropdown-toggle="compareAllDropdown"
      data-dropdown-offset-skidding="300"
      data-dropdown-placement="bottom"
      class="border border-brightGray-200 rounded-md py-1.5 pl-3 flex items-center"
      type="button"
    >
      <span class="min-w-[6em]">チーム全員と比較</span>
      <span
        class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-7px] before:bg-brightGray-200 before:w-[1px] before:h-[38px]"
        >add</span>
    </button>
    <!-- チーム全員と比較Downdrop -->
    <div
      class="bg-white rounded-md mt-1 w-[750px] border border-brightGray-100 shadow-md hidden"
      id="compareAllDropdown"
    >
      <.live_component
        id="related_team_card_compare"
        module={BrightWeb.CardLive.RelatedTeamCardComponent}
        current_user={@current_user}
        show_menue={false}
      />
    </div>
    """
  end

  def compare_custom_group(assigns) do
    ~H"""
    <button
      id="addCustomGroupDropwonButton"
      data-dropdown-toggle="addCustomGroupDropwon"
      data-dropdown-offset-skidding="230"
      data-dropdown-placement="bottom"
      type="button"
      class="text-brightGray-600 bg-white px-2 py-2 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
    >
      カスタムグループ
    </button>
    <!-- カスタムグループDropdown -->
    <div
      id="addCustomGroupDropwon"
      class="z-10 hidden bg-white rounded-lg shadow-md min-w-[286px] border border-brightGray-50"
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
            下記をカスタムグループとして追加する
          </a>
        </li>
        <li>
          <a
            href="#"
            class="block px-4 py-3 hover:bg-brightGray-50 text-base hover:cursor-pointer"
            >下記で現在のカスタムグループを更新する</a>
        </li>
      </ul>
    </div>

    <!-- カスタムグループ福岡Elixir -->
    <div class="text-left flex items-center text-base">
      <span
        class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-1 !items-center !justify-center"
        >group</span>
      カスタムグループ福岡Elixir
    </div>
    """
  end
end
