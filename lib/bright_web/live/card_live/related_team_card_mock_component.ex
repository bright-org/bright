defmodule BrightWeb.CardLive.RelatedTeamCardMockComponent do
  use BrightWeb, :live_component

  def render(assigns) do
    ~H"""
    <div
      class="text-sm font-medium text-center text-brightGray-500"
    >
      <ul
        class="flex content-between border-b border-brightGray-200"
      >
        <li class="w-full">
          <a
            href="#"
            class="py-3.5 w-full items-center justify-center inline-block text-brightGreen-300 font-bold border-brightGreen-300 border-b-2"
            >所属チーム</a>
        </li>
        <li class="w-full">
          <a
            href="#"
            class="py-3.5 w-full items-center justify-center inline-block"
            >管轄チーム</a>
        </li>
        <li class="w-full">
          <a
            href="#"
            class="py-3.5 w-full items-center justify-center inline-block"
            >カスタムグループ</a>
        </li>
      </ul>
      <div class="pt-4 pb-1 px-6">
        <ul class="flex gap-y-1.5 flex-col">
          <li
            class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded"
          >
            <img
              src="/images/common/icons/team.svg"
              class="mr-2"
            />Elixir Fukuoka
          </li>

          <li
            class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded"
          >
            <img
              src="/images/common/icons/other_team.svg"
              class="mr-2"
            />
            圧倒的開発スピード
          </li>

          <li
            class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded"
          >
            <img
              src="/images/common/icons/management_team.svg"
              class="mr-2"
            />
            S社案件開発
          </li>
          <li
            class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded"
          >
            <img
              src="/images/common/icons/coustom_group.svg"
              class="mr-2"
            />
            D社スマホアプリプロジェクト
          </li>
          <li
            class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded"
          >
            <img
              src="/images/common/icons/other_team.svg"
              class="mr-2"
            />
            D社スマホアプリプロジェクト
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
    """
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
