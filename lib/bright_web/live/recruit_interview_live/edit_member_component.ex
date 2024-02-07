defmodule BrightWeb.RecruitInterviewLive.EditMemberComponent do
  alias Bright.Recruits
  use BrightWeb, :live_component

  alias Bright.UserSearches
  alias Bright.RecruitmentStockUsers
  alias Bright.Recruits.InterviewMember

  @impl true
  def render(assigns) do
    ~H"""
    <div id="interview_member_edit_modal">
      <div class="bg-pureGray-600/90 transition-opacity z-[55]" />
      <div class="overflow-y-auto z-[60]">
        <main class="flex items-center justify-center" role="main">
          <section class="bg-white px-10 py-8 shadow text-sm w-full">
            <h2 class="font-bold text-3xl">
              <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
                面談検討
              </span>
            </h2>

            <div :if={@interview_member} class="flex mt-8">
              <div class="border-r border-r-brightGray-200 border-dashed mr-8 pr-8 w-[860px]">
                <div>
                  <h3 class="font-bold text-base">候補者</h3>
                  <.live_component
                    id="user_params_for_interview"
                    prefix="interview"
                    anon={true}
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
                <h3 class="font-bold text-xl">調整内容</h3>
                <div class="bg-brightGray-10 mt-4 rounded-sm px-10 py-6">
                  <dl class="flex flex-wrap w-full">
                    <dt class="font-bold w-[98px] flex items-center mb-10">
                      対象面談
                    </dt>
                    <dd class="w-[280px] mb-10 break-words">
                        <span><%= if @interview_member.interview.skill_panel_name == nil, do: "スキルパネルデータなし", else: @interview_member.interview.skill_panel_name %></span>
                        <br />
                        <span class="text-brightGray-300">
                        <%= NaiveDateTime.to_date(@interview_member.inserted_at) %>
                        希望年収:<%= @interview_member.interview.desired_income %>
                        </span>
                      </dd>

                    <dt class="font-bold w-[98px] flex">
                      <label for="point" class="block pr-1">候補者の推しポイントや<br />確認・注意点</label>
                    </dt>
                    <dd class="w-[280px] break-words">
                    <%= @interview_member.interview.comment %>
                    </dd>
                    <dt class="font-bold w-[98px] flex mt-8" >
                      <label for="point" class="block pr-1">参加の<br />意思確認</label>
                    </dt>
                    <dd class="w-[280px] mt-8">
                      <label class="block">
                        <input
                          type="radio" name="interview" class="mr-1"
                          phx-click={JS.push("checked", target: @myself, value: %{decision: :wants})}
                        >
                        <span class="align-[2px]">同席したい</span>
                      </label>
                      <label class="block">
                        <input
                          type="radio" name="interview" class="mr-1"
                          phx-click={JS.push("checked", target: @myself, value: %{decision: :keep})}
                        >
                        <span class="align-[2px]">今は同席しないが候補者をストック</span>
                      </label>
                      <label class="block">
                        <input
                          type="radio" name="interview" class="mr-1"
                          phx-click={JS.push("checked", target: @myself, value: %{decision: :not_wants})}
                        >
                        <span class="align-[2px]">同席を希望しない</span>
                      </label>
                    </dd>
                  </dl>
                </div>
                <div class="flex justify-end gap-x-4 mt-16">
                  <button
                    class="text-sm font-bold py-3 rounded text-white bg-base w-72"
                    phx-click={JS.push("submit", target: @myself)}
                  >
                    確定する
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
    |> assign(:candidates_user, [])
    |> assign(:skill_params, %{})
    |> then(&{:ok, &1})
  end

  @impl true
  def update(%{interview_member: %InterviewMember{}} = assigns, socket) do
    skill_params =
      assigns.interview_member.interview.skill_params
      |> Jason.decode!()
      |> Enum.map(fn s ->
        s
        |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
        |> Enum.into(%{})
      end)

    user =
      UserSearches.get_user_by_id_with_job_profile_and_skill_score(
        assigns.interview_member.interview.candidates_user_id,
        skill_params
      )

    socket
    |> assign(assigns)
    |> assign(:skill_params, skill_params)
    |> assign(:candidates_user, user)
    |> assign(:decision, assigns.interview_member.decision)
    |> then(&{:ok, &1})
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("checked", %{"decision" => decision}, socket) do
    {:noreply, assign(socket, :decision, decision)}
  end

  def handle_event("submit", _params, %{assigns: %{decision: "keep"} = assigns} = socket) do
    interview = assigns.interview_member.interview

    %{
      recruiter_id: assigns.interview_member.user_id,
      user_id: interview.candidates_user_id,
      skill_panel: interview.skill_panel_name,
      desired_income: interview.desired_income
    }
    |> RecruitmentStockUsers.create_recruitment_stock_user()

    Recruits.send_interview_acceptance_notification_mail(
      socket.assigns.current_user,
      interview.id,
      &url(~p"/recruits/interviews/#{&1}")
    )

    Recruits.update_interview_member(assigns.interview_member, %{decision: :keep})
    {:noreply, push_navigate(socket, to: ~p"/recruits/interviews")}
  end

  def handle_event("submit", _params, %{assigns: assigns} = socket) do
    interview = assigns.interview_member.interview
    Recruits.update_interview_member(assigns.interview_member, %{decision: assigns.decision})

    Recruits.send_interview_acceptance_notification_mail(
      socket.assigns.current_user,
      interview.id,
      &url(~p"/recruits/interviews/#{&1}")
    )

    {:noreply, push_navigate(socket, to: ~p"/recruits/interviews")}
  end
end
