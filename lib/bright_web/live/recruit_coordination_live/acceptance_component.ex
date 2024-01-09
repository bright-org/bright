defmodule BrightWeb.RecruitCoordinationLive.AcceptanceComponent do
  use BrightWeb, :live_component

  alias Bright.Recruits

  def render(assigns) do
    ~H"""
    <div id="acceptance_modal">
      <div class="bg-pureGray-600/90 transition-opacity z-[55]" />
      <div class="overflow-y-auto z-[60]">
      <main class="flex items-center justify-center" role="main">
        <section class="bg-white px-10 py-8 shadow text-sm">
        <h2 class="font-bold text-xl">
        <span class="before:bg-bgGemSales before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[8px] before:w-9">選考結果</span>
        </h2>

        <div class="mt-8">
          <!-- コメント表示 -->
          <div class="mt-4 overflow-y-auto">
            <p class="w-full break-words">
              <%= @employment.message %>
            </p>
            <label class="items-center flex mt-8 w-full">
              <span class="font-bold py-1 mr-4">雇用形態</span>
              <span><%= @employment.employment_status %></span>
            </label>

            <label class="items-center flex mt-8 w-full">
              <span class="font-bold py-1 mr-4">年収もしくは契約額</span>
              <span><%= @employment.income %></span>
              <span class="ml-1">万円</span>
            </label>
          </div>

        <div class="flex justify-center gap-x-4 mt-16 pb-2 relative w-full">
          <button
              class="text-sm font-bold px-2 py-2 rounded border bg-base text-white w-60"
          >
            採用を受諾する
          </button>

          <!-- 採用を辞退する -->
          <button
            id="noAdoptionDropdownButton"
            data-dropdown-toggle="noAdoptionDropdown"
            data-dropdown-offset-skidding="300"
            data-dropdown-placement="bottom"
            class="border border-brightGray-200 rounded-md py-1.5 pl-3 flex items-center"
            type="button"
          >
            <span class="min-w-[6em]">採用を辞退する</span>
            <span
              class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-7px] before:bg-brightGray-200 before:w-[1px] before:h-[38px]"
              >add</span>
          </button>
          <!-- 採用を辞退する Donwdrop -->
          <div
            id="menu01"
            class="hidden absolute z-10 bg-white rounded-lg shadow-md min-w-[286px] top-10 left-[310px]"
          >
            <ul
              class="p-2 text-left text-base"
              aria-labelledby="dropmenu04"
            >
              <li>
                <a
                  href="#"
                  class="block px-4 py-3 hover:bg-brightGray-50 text-base"
                  >金額が合わない</a>
              </li>
              <li>
                <a
                  data-modal-target="addTeamModal"
                  data-modal-toggle="addTeamModal"
                  class="block px-4 py-3 hover:bg-brightGray-50 text-base"
                  >状況が変わった</a>
              </li>
              <li>
                <a
                  href="#"
                  class="block px-4 py-3 hover:bg-brightGray-50 text-base"
                  >スカウト時と条件が異なる</a>
              </li>
              <li>
                <a
                  href="#"
                  class="block px-4 py-3 hover:bg-brightGray-50 text-base"
                  >相性が悪い</a>
              </li>
            </ul>
          </div>
        </div>
        </div>

        </section>
      </main>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    employment =
      Recruits.get_employment_acceptance!(assigns.employment_id, assigns.current_user.id)

    socket
    |> assign(assigns)
    |> assign(:employment, employment)
    |> then(&{:ok, &1})
  end
end
