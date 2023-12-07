defmodule BrightWeb.RecruitCoordinationLive.CancelComponent do
  use BrightWeb, :live_component

  alias Bright.Recruits
  alias Bright.UserSearches

  import BrightWeb.ProfileComponents, only: [profile_small: 1]
  import Bright.UserProfiles, only: [icon_url: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="coordination_edit_modal">
      <div class="bg-pureGray-600/90 transition-opacity z-[55]" />
      <div class="overflow-y-auto z-[60]">
        <main class="flex items-center justify-center" role="main">
          <section class="bg-white px-10 py-8 shadow text-sm w-full">
            <h2 class="font-bold text-3xl">
              <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
                採用調整
              </span>
            </h2>

            <div :if={@coordination} class="flex mt-8">
              <div class="border-r border-r-brightGray-200 border-dashed mr-8 pr-8 w-[860px]">
                <div>
                  <h3 class="font-bold text-base">候補者</h3>
                  <.live_component
                    id="user_params_for_coordination"
                    prefix="interview"
                    search={false}
                    anon={true}
                    module={BrightWeb.SearchLive.SearchResultsComponent}
                    current_user={@current_user}
                    result={@candidates_user}
                    skill_params={@skill_params}
                    stock_user_ids={[]}
                  />
                </div>

              </div>

            <div class="w-[493px]">
              <h3 class="font-bold text-xl">面談内容</h3>
              <div class="bg-brightGray-10 mt-4 rounded-sm px-10 py-6">
                  <dl class="flex flex-wrap w-full">
                    <dt class="font-bold w-[98px] flex items-center mb-10">
                      面談名
                    </dt>
                    <dd class="w-[280px] mb-10 break-words">
                      <span><%= if @coordination.skill_panel_name == nil, do: "スキルパネルデータなし", else: @coordination.skill_panel_name %></span>
                      <br />
                      <span class="text-brightGray-300">
                        <%= NaiveDateTime.to_date(@coordination.inserted_at) %>
                        希望年収:<%= @coordination.desired_income %>
                      </span>
                    </dd>
                    <dt class="font-bold w-[98px] flex items-center mb-10">
                      面談依頼者
                    </dt>
                    <dd class="w-[280px] mb-10">
                      なし
                    </dd>
                    <dt class="font-bold w-[98px] mb-10">同席候補者</dt>
                    <dd class="min-w-[280px]">
                      <ul class="flex flex-col gap-y-1">
                      <%= for member <- @coordination.coordination_members do %>
                        <div class="flex">
                          <div class="w-[200px] truncate mr-4">
                          <.profile_small
                            user_name={member.user.name}
                            icon_file_path={icon_url(member.user.user_profile.icon_file_path)}
                          />
                          </div>
                          <div class="mt-4">
                            <span><%= Gettext.gettext(BrightWeb.Gettext, to_string(member.decision)) %></span>
                          </div>
                        </div>
                      <% end %>
                      </ul>
                    </dd>
                    <p class="text-attention-600">
                    <%= @no_answer_error %>
                    </p>
                    <dt class="font-bold w-[98px] flex mt-16">
                      <label for="point" class="block pr-1">候補者の推しポイントや<br />確認・注意点</label>
                    </dt>
                    <dd class="w-[280px] mt-16">
                    <div class="px-5 py-2 border border-brightGray-100 rounded-sm flex-1 w-full break-words">
                      <%= @coordination.comment %>
                    </div>
                    </dd>
                  </dl>
                </div>
                <div class="flex justify-start gap-x-4 mt-4">
                  <button class="text-sm font-bold py-3 rounded border border-base w-44 h-12">
                    <.link navigate={@return_to}>閉じる</.link>
                  </button>
                  <div>
                    <button
                      phx-click={JS.show(to: "#menu01")}
                      type="button"
                      class="text-sm font-bold py-3 pl-3 rounded text-white bg-base w-40 flex items-center"
                    >
                      <span class="min-w-[6em]">採用キャンセル</span>
                      <span class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-9px] before:bg-brightGray-200 before:w-[1px] before:h-[42px]">add</span>
                    </button>

                    <div
                      id="menu01"
                      phx-click-away={JS.hide(to: "#menu01")}
                      class="hidden absolute bg-white rounded-lg shadow-md min-w-[286px]"
                    >
                      <ul class="p-2 text-left text-base">
                        <li
                          phx-click={JS.push("decision", target: @myself, value: %{decision: :cancel_coordination, reason: "条件が合わない"})}
                          class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                        >
                          条件が合わない
                        </li>
                        <li
                          phx-click={JS.push("decision", target: @myself, value: %{decision: :cancel_coordination, reason: "状況が変わった"})}
                          class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                        >
                          状況が変わった
                        </li>
                        <li
                          phx-click={JS.push("decision", target: @myself, value: %{decision: :cancel_coordination, reason: "スカウト時と状況が異なる"})}
                          class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                        >
                          スカウト時と状況が異なる
                        </li>
                        <li
                          phx-click={JS.push("decision", target: @myself, value: %{decision: :cancel_coordination, reason: "相性が悪い"})}
                          class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                        >
                          相性が悪い
                        </li>
                      </ul>
                    </div>
                  </div>
                  <button class="text-sm font-bold py-3 rounded border border-base w-44 h-12">
                    <.link navigate={@return_to}>採用決定</.link>
                  </button>

                </div>
              </div>
          </div>
          </section>
        </main>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket
    |> assign(:search_results, [])
    |> assign(:candidates_user, [])
    |> assign(:skill_params, %{})
    |> assign(:coordination, nil)
    |> assign(:no_answer_error, "")
    |> then(&{:ok, &1})
  end

  @impl true
  def update(%{coordination_id: coordination_id, current_user: current_user} = assigns, socket) do
    coordination = Recruits.get_coordination_with_member_users!(coordination_id, current_user.id)

    skill_params =
      coordination.skill_params
      |> Jason.decode!()
      |> Enum.map(fn s ->
        s
        |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
        |> Enum.into(%{})
      end)

    user =
      UserSearches.get_user_by_id_with_job_profile_and_skill_score(
        coordination.candidates_user_id,
        skill_params
      )

    socket
    |> assign(assigns)
    |> assign(:coordination, coordination)
    |> assign(:skill_params, skill_params)
    |> assign(:candidates_user, user)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("decision", %{"decision" => status, "reason" => reason}, socket) do
    {:ok, _coordination} =
      Recruits.update_coordination(socket.assigns.coordination, %{
        status: status,
        cancel_reason: reason
      })

    # Recruits.send_coordination_cancel_notification_mails(coordination.id)

    {:noreply, push_navigate(socket, to: ~p"/recruits/coordinations")}
  end
end
