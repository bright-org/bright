defmodule BrightWeb.RecruitLive.EditInterviewComponent do
  use BrightWeb, :live_component

  alias Bright.Recruits
  alias Bright.Recruits.Interview
  alias Bright.UserSearches

  import BrightWeb.ProfileComponents, only: [profile_small: 1]
  import Bright.UserProfiles, only: [icon_url: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="interview_edit_modal">
      <div class="bg-pureGray-600/90 transition-opacity z-[55]" />
      <div class="overflow-y-auto z-[60]">
        <main class="flex items-center justify-center" role="main">
          <section class="bg-white px-10 py-8 shadow text-sm w-full">
            <h2 class="font-bold text-3xl">
              <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
                面談調整
              </span>
            </h2>

            <div :if={@interview} class="flex mt-8">
              <div class="border-r border-r-brightGray-200 border-dashed mr-8 pr-8 w-[860px]">
                <div>
                  <h3 class="font-bold text-base">採用候補者</h3>
                  <.live_component
                    id="user_params_for_interview"
                    prefix="interview"
                    search={false}
                    module={BrightWeb.SearchLive.SearchResultsComponent}
                    current_user={@current_user}
                    result={@candidates_user}
                    skill_params={@skill_params}
                    stock_user_ids={[]}
                  />
                </div>
              </div>
          <!-- Start 面談調整内容 -->
            <div class="w-[493px]">
              <h3 class="font-bold text-xl">面談調整内容</h3>
                <div class="bg-brightGray-10 mt-4 rounded-sm px-10 py-6">
                  <dl class="flex flex-wrap w-full">
                    <dt class="font-bold w-[98px] flex items-center mb-10">
                      面談名
                    </dt>
                    <dd class="w-[280px] mb-10">
                      <%= @interview.name %>
                    </dd>
                    <dt
                      class="font-bold w-[98px] flex items-center mb-10"
                    >
                      依頼者
                    </dt>
                    <dd class="w-[280px] mb-10">
                      なし
                    </dd>

                    <dt class="font-bold w-[98px] mb-10">面談参加者</dt>
                    <dd class="min-w-[280px]">
                      <ul class="flex flex-col gap-y-1">
                      <%= for member <- @interview.interview_members do %>
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
                    <dt class="font-bold w-[98px] flex mt-16">
                      <label for="point" class="block pr-1">採用候補者の推しポイント<br />注意点</label>
                    </dt>
                    <dd class="w-[280px] mt-16">
                    <div class="px-5 py-2 border border-brightGray-100 rounded-sm flex-1 w-full">
                      <%= @interview.comment %>
                    </div>
                    </dd>
                  </dl>
                </div>
                <div class="flex justify-end gap-x-4 mt-16">
                  <button
                    phx-click={JS.push("decision", target: @myself, value: %{decision: :dismiss_interview})}
                    class="text-sm font-bold py-3 rounded border border-base w-72"
                  >
                    面談キャンセル
                  </button>

                  <button
                    phx-click={JS.push("decision", target: @myself, value: %{decision: :consume_interview})}
                    class="text-sm font-bold py-3 rounded text-white bg-base w-72"
                  >
                    面談決定
                  </button>
                </div>
            </div><!-- End 面談調整内容 -->
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
    |> assign(:members, [])
    |> assign(:interview, nil)
    |> assign(:candidate_error, "")
    |> then(&{:ok, &1})
  end

  @impl true
  def update(%{interview: %Interview{}} = assigns, socket) do
    skill_params =
      assigns.interview.skill_params
      |> Jason.decode!()
      |> Enum.map(fn s ->
        s
        |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
        |> Enum.into(%{})
      end)

    user =
      UserSearches.get_user_by_id_with_job_profile_and_skill_score(
        assigns.interview.candidates_user_id,
        skill_params
      )

    socket
    |> assign(assigns)
    |> assign(:skill_params, skill_params)
    |> assign(:candidates_user, user)
    |> then(&{:ok, &1})
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("decision", %{"decision" => decision}, socket) do
    Recruits.update_interview(socket.assigns.interview, %{status: decision})

    {:noreply, push_navigate(socket, to: ~p"/recruits/interviews")}
  end
end
