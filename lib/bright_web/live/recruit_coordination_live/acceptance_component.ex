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
            <h2 class="font-bold text-xl"><span class="before:bg-bgGemSales before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[8px] before:w-9">選考結果</span></h2>
            <p class="mt-2 text-lg">※採用辞退で選択した理由は採用担当者には送信されません</p>
            <div class="mt-8">
              <div class="mt-4 overflow-y-auto">
                <p class="w-full break-words">
                  <%= raw(String.replace(@employment.message, ~r/\n/, "<br />")) %>
                </p>
                <label class="items-center flex mt-8 w-full">
                  <span class="font-bold py-1 mr-4">雇用形態</span>
                  <span><%= Gettext.gettext(BrightWeb.Gettext, to_string(@employment.employment_status)) %></span>
                </label>

                <label class="items-center flex mt-8 w-full">
                  <span class="font-bold py-1 mr-4">年収もしくは契約額</span>
                  <span><%= @employment.income %></span>
                  <span class="ml-1">万円</span>
                </label>
              </div>

              <div class="flex justify-start gap-x-4 mt-4">
                <button class="text-sm font-bold py-3 rounded border border-base w-44 h-12">
                  <.link navigate={@patch}>閉じる</.link>
                </button>
                <div>
                  <button
                    phx-click={JS.show(to: "#menu01")}
                    phx-target={@myself}
                    type="button"
                    class="text-sm font-bold py-3 pl-3 rounded text-white bg-base w-40 flex items-center"
                  >
                    <span class="min-w-[6em]">採用辞退</span>
                    <span class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-9px] before:bg-brightGray-200 before:w-[1px] before:h-[42px]">add</span>
                  </button>

                  <div
                    id="menu01"
                    phx-click-away={JS.hide(to: "#menu01")}
                    class="hidden absolute bg-white rounded-lg shadow-md min-w-[286px]"
                  >
                    <ul class="p-2 text-left text-base">
                      <li
                        phx-click={JS.push("decision", target: @myself, value: %{reason: "採用担当者の採用条件に添えない"})}
                        class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                      >
                        採用担当者の採用条件に添えない
                      </li>
                      <li
                        phx-click={JS.push("decision", target: @myself, value: %{reason: "自身のスキルが案件とマッチしない"})}
                        class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                      >
                        自身のスキルが案件とマッチしない
                      </li>
                      <li
                        phx-click={JS.push("decision", target: @myself, value: %{reason: "当方の状況が変わって中断"})}
                        class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                      >
                        当方の状況が変わって中断
                      </li>
                    </ul>
                  </div>
                </div>
                <button
                  class="text-sm font-bold py-3 rounded text-white bg-base w-44 h-12"
                  phx-click="accept"
                  phx-target={@myself}
                >
                  採用受諾する
                </button>
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

  def handle_event("accept", _params, socket) do
    employment = socket.assigns.employment

    {:ok, _employment} =
      Recruits.update_employment(employment, %{status: "acceptance_emplyoment"})

    Recruits.deliver_accept_employment_email_instructions(
      employment.candidates_user,
      employment.recruiter_user,
      employment,
      &url(~p"/recruits/employments/#{&1}")
    )

    {:noreply, push_navigate(socket, to: ~p"/recruits/coordinations")}
  end

  def handle_event("decision", %{"reason" => reason}, socket) do
    employment = socket.assigns.employment

    {:ok, _employment} =
      Recruits.update_employment(employment, %{
        status: :cancel_candidates,
        candidates_reason: reason
      })

    Recruits.deliver_cancel_employment_email_instructions(
      employment.candidates_user,
      employment.recruiter_user
    )

    {:noreply, push_navigate(socket, to: ~p"/recruits/coordinations")}
  end
end
