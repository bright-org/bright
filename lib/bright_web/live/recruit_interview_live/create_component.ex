defmodule BrightWeb.RecruitInterviewLive.CreateComponent do
  use BrightWeb, :live_component

  alias Bright.Accounts
  alias Bright.UserSearches
  alias Bright.SkillPanels
  alias Bright.Recruits
  alias Bright.Recruits.Interview
  alias BrightWeb.BrightCoreComponents, as: BrightCore
  import BrightWeb.ProfileComponents, only: [profile_small_with_remove_button: 1]

  def render(assigns) do
    ~H"""
    <div id="create_interview_modal" class="hidden">
      <div class="bg-pureGray-600/90 fixed inset-0 transition-opacity z-[55]" />
      <div class="fixed inset-0 overflow-y-auto z-[60]">
        <main class="flex h-screen items-center justify-center w-screen" role="main">
          <section class="absolute bg-white px-10 py-8 shadow text-sm top-20 w-[1500px]">
            <h2 class="font-bold text-3xl">
              <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
                面談の打診
              </span>
            </h2>

            <div class="flex mt-8">
              <div class="border-r border-r-brightGray-200 border-dashed mr-8 pr-8 w-[860px]">
                <div>
                  <h3 class="font-bold text-xl">候補者</h3>
                  <.live_component
                    id="user_params"
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

                <div class="mt-8">
                  <h3 class="font-bold text-base">面談への同席を依頼したい人<span class="font-normal">を選んでください</span></h3>
                  <.live_component
                    id="recruit_card"
                    module={BrightWeb.CardLive.RelatedRecruitUserCardComponent}
                    current_user={@current_user}
                    target="#create_interview_modal"
                    event="add_user"
                  />
                  <span class="text-attention-600"><%= @candidate_error %></span>
                </div>
              </div>
          <!-- Start 面談調整内容 -->
            <div class="w-[493px]">
              <h3 class="font-bold text-xl">打診内容</h3>
              <.form
                for={@interview_form}
                id="interview_form"
                phx-target={@myself}
                phx-submit="create_interview"
                phx-change="validate_interview"
              >
                <div class="bg-brightGray-10 mt-4 rounded-sm px-10 py-6">
                  <dl class="flex flex-wrap w-full">
                    <dt class="font-bold w-[98px] mb-10">同席依頼先</dt>
                    <dd class="w-[280px]">
                      <ul class="flex flex-wrap gap-y-1">
                      <%= for user <- @users do %>
                        <.profile_small_with_remove_button
                          remove_user_target={@myself}
                          user_id={user.id} user_name={user.name}
                          title={user.user_profile.title}
                          icon_file_path={user.user_profile.icon_file_path}
                        />
                      <% end %>
                      </ul>
                    </dd>
                    <dt class="font-bold w-[98px] flex mt-16">
                      <label for="point" class="block pr-1">候補者の推しポイントや<br />確認・注意点</label>
                    </dt>
                    <dd class="w-[280px] mt-16">
                    <BrightCore.input
                      error_class="ml-[100px] mt-2"
                      field={@interview_form[:comment]}
                      type="textarea"
                      required
                      rows="5"
                      cols="30"
                      input_class="px-5 py-2 border border-brightGray-100 rounded-sm flex-1 w-full"
                    />
                    </dd>
                  </dl>
                </div>
                <div class="flex justify-end gap-x-4 mt-16">
                  <button
                    class="text-sm font-bold py-3 rounded text-white bg-base w-72"
                  >
                    面談を打診する
                  </button>
                </div>
              </.form>
            </div><!-- End 面談調整内容 -->
          </div>
            <div>
              <button
                class="absolute right-5 top-5 z-10"
                phx-click={JS.hide(to: "#create_interview_modal")}
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
    |> assign(:candidates_user, [])
    |> assign(:skill_params, %{})
    |> assign(:users, [])
    |> assign(:candidate_error, "")
    |> then(&{:ok, &1})
  end

  def update(assigns, socket) do
    interview = %Interview{}
    changeset = Recruits.change_interview(interview)

    socket
    |> assign(assigns)
    |> assign(:interview, interview)
    |> assign_interview_form(changeset)
    |> then(&{:ok, &1})
  end

  def handle_event("validate_interview", %{"interview" => interview_params}, socket) do
    changeset =
      socket.assigns.interview
      |> Interview.changeset(interview_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_interview_form(socket, changeset)}
  end

  def handle_event("open", %{"user" => user_id, "skill_params" => skill_params}, socket) do
    skill_params =
      skill_params
      |> Enum.map(&(Enum.map(&1, fn {k, v} -> {String.to_atom(k), v} end) |> Enum.into(%{})))

    user = UserSearches.get_user_by_id_with_job_profile_and_skill_score(user_id, skill_params)

    socket
    |> assign(:candidates_user, user)
    |> assign(:skill_params, skill_params)
    |> then(&{:noreply, &1})
  end

  def handle_event("add_user", %{"name" => name}, socket) do
    user = Accounts.get_user_by_name_or_email(name)
    users = socket.assigns.users

    cond do
      id_duplidated_user?(users, user) ->
        {:noreply, assign(socket, :candidate_error, "対象のユーザーは既に追加されています")}

      Enum.count(users) >= 4 ->
        {:noreply, assign(socket, :candidate_error, "同席依頼先の上限は４名です")}

      true ->
        socket
        |> assign(:users, users ++ [user])
        |> assign(:candidate_error, "")
        |> then(&{:noreply, &1})
    end
  end

  def handle_event("remove_user", %{"id" => id}, socket) do
    # メンバーユーザー一時リストから削除
    removed_users = Enum.reject(socket.assigns.users, fn x -> x.id == id end)
    {:noreply, assign(socket, :users, removed_users)}
  end

  def handle_event(
        "create_interview",
        %{"interview" => interview_params},
        %{assigns: %{skill_params: skill_params, users: users, current_user: recruiter}} = socket
      ) do
    candidates_user = socket.assigns.candidates_user |> List.first()

    interview_params =
      Map.merge(interview_params, %{
        "skill_panel_name" => gen_interview_name(skill_params),
        "desired_income" => candidates_user.desired_income,
        "skill_params" => Jason.encode!(skill_params),
        "interview_members" => Enum.map(users, &%{"user_id" => &1.id}),
        "recruiter_user_id" => recruiter.id,
        "candidates_user_id" => candidates_user.id
      })

    case Recruits.create_interview(interview_params) do
      {:ok, interview} ->
        preloaded_interview =
          Recruits.get_interview_with_member_users!(interview.id, recruiter.id)

        # 追加したメンバー全員に可否メールを送信する。
        send_acceptance_mails(preloaded_interview, recruiter)

        # メール送信の成否に関わらず正常終了とする
        # TODO メール送信エラーを運用上検知する必要がないか?

        {:noreply, redirect(socket, to: ~p"/recruits/interviews")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_interview_form(socket, changeset)}
    end
  end

  defp send_acceptance_mails(interview, recruiter) do
    interview.interview_members
    |> Enum.each(fn member ->
      Recruits.deliver_acceptance_email_instructions(
        recruiter,
        member.user,
        member,
        &url(~p"/recruits/interviews/member/#{&1}")
      )
    end)
  end

  defp id_duplidated_user?(users, user) do
    users |> Enum.find(fn u -> user.id == u.id end) |> is_nil() |> then(&(!&1))
  end

  defp assign_interview_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :interview_form, to_form(changeset))
  end

  defp gen_interview_name(skill_params) do
    skill_params
    |> List.first()
    |> Map.get(:skill_panel)
    |> SkillPanels.get_skill_panel!()
    |> Map.get(:name)
  end
end
