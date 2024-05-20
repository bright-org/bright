defmodule BrightWeb.RecruitCoordinationLive.CreateComponent do
  use BrightWeb, :live_component

  alias Bright.Accounts
  alias Bright.UserSearches
  alias Bright.SkillPanels
  alias Bright.Recruits
  alias Bright.Recruits.Coordination
  alias BrightWeb.BrightCoreComponents, as: BrightCore
  import BrightWeb.ProfileComponents, only: [profile_small_with_remove_button: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="create_coordination_modal">
      <div class="bg-pureGray-600/90 transition-opacity z-[55]" />
      <div class="overflow-y-auto z-[60]">
        <main class="flex items-center justify-center " role="main">
          <section class="bg-white px-10 py-8 shadow text-sm w-full">
            <h2 class="font-bold text-3xl">
              <span class="before:bg-bgGemSales before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[8px] before:w-9">
                採用選考
              </span>
            </h2>

            <div class="flex mt-8">
              <div class="border-r border-r-brightGray-200 border-dashed mr-8 pr-8 w-[860px]">
                <div>
                  <h3 class="font-bold text-xl">候補者</h3>
                  <.live_component
                    id="user_params_coordination"
                    prefix="interview"
                    search={false}
                    anon={false}
                    module={BrightWeb.SearchLive.SearchResultsComponent}
                    current_user={@current_user}
                    result={@candidates_user}
                    skill_params={@skill_params}
                    stock_user_ids={[]}
                  />
                </div>

                <div class="mt-8">
                  <h3 class="font-bold text-base">
                    採用選考を依頼したい人<span class="font-normal">を選んでください</span>
                  </h3>
                  <.live_component
                    id="recruit_card_coordination"
                    module={BrightWeb.CardLive.RelatedRecruitUserCardComponent}
                    current_user={@current_user}
                    target="#create_coordination_modal"
                    event="add_user"
                  />
                  <span class="text-attention-600"><%= @candidate_error %></span>
                </div>
              </div>
              <!-- Start 面談調整内容 -->
              <div class="w-[493px]">
                <h3 class="font-bold text-xl">調整内容</h3>
                <.form
                  for={@coordination_form}
                  id="coordination_form"
                  phx-target={@myself}
                  phx-submit="create_coordination"
                  phx-change="validate_coordination"
                >
                  <div class="bg-brightGray-10 mt-4 rounded-sm px-10 py-6">
                    <dl class="flex flex-wrap w-full">
                      <dt class="font-bold w-[98px] mb-10">選考依頼先</dt>
                      <dd class="w-[280px]">
                        <ul class="flex flex-wrap gap-y-1">
                          <%= for user <- @users do %>
                            <.profile_small_with_remove_button
                              remove_user_target={@myself}
                              user_id={user.id}
                              user_name={user.name}
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
                          field={@coordination_form[:comment]}
                          type="textarea"
                          required
                          rows="5"
                          cols="30"
                          input_class="px-5 py-2 border border-brightGray-100 rounded-sm flex-1 w-full"
                        />
                      </dd>
                    </dl>
                  </div>
                  <div class="flex justify-start gap-x-4 mt-4">
                    <button class="text-sm font-bold py-3 rounded border border-base w-44 h-12">
                      <.link navigate={@patch}>閉じる</.link>
                    </button>
                    <div>
                      <button
                        phx-click={JS.show(to: "#menu01")}
                        type="button"
                        class="text-sm font-bold py-3 pl-3 rounded text-white bg-base w-40 flex items-center"
                      >
                        <span class="min-w-[6em]">選考キャンセル</span>
                        <span class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-9px] before:bg-brightGray-200 before:w-[1px] before:h-[42px]">
                          add
                        </span>
                      </button>

                      <div
                        id="menu01"
                        phx-click-away={JS.hide(to: "#menu01")}
                        class="hidden absolute bg-white rounded-lg shadow-md min-w-[286px]"
                      >
                        <ul class="p-2 text-left text-base">
                          <li
                            phx-click={
                              JS.push("decision",
                                target: @myself,
                                value: %{decision: :cancel_interview, reason: "候補者の希望条件に添えない"}
                              )
                            }
                            class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                          >
                            候補者の希望条件に添えない
                          </li>
                          <li
                            phx-click={
                              JS.push("decision",
                                target: @myself,
                                value: %{decision: :cancel_interview, reason: "候補者のスキルが案件とマッチしない"}
                              )
                            }
                            class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                          >
                            候補者のスキルが案件とマッチしない
                          </li>
                          <li
                            phx-click={
                              JS.push("decision",
                                target: @myself,
                                value: %{decision: :cancel_interview, reason: "候補者のスキルが登録内容より不足"}
                              )
                            }
                            class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                          >
                            候補者のスキルが登録内容より不足
                          </li>
                          <li
                            phx-click={
                              JS.push("decision",
                                target: @myself,
                                value: %{decision: :cancel_interview, reason: "当方の状況が変わって中断"}
                              )
                            }
                            class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                          >
                            当方の状況が変わって中断
                          </li>
                        </ul>
                      </div>
                    </div>
                    <button
                      class="text-sm font-bold py-3 rounded text-white bg-base w-44 h-12"
                      type="submit"
                    >
                      採用選考する
                    </button>
                  </div>
                </.form>
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
    |> assign(:users, [])
    |> assign(:candidate_error, "")
    |> assign(:coordination_form, nil)
    |> then(&{:ok, &1})
  end

  @impl true
  def update(%{interview_id: interview_id, current_user: current_user} = assigns, socket) do
    interview = Recruits.get_interview_with_member_users!(interview_id, current_user.id)

    skill_params =
      interview.skill_params
      |> Jason.decode!()
      |> Enum.map(fn s ->
        s
        |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
        |> Enum.into(%{})
      end)

    user =
      UserSearches.get_user_by_id_with_job_profile_and_skill_score(
        interview.candidates_user_id,
        skill_params
      )

    coordination = %Coordination{}
    changeset = Recruits.change_coordination(coordination)

    socket
    |> assign(assigns)
    |> assign(:interview, interview)
    |> assign(:skill_params, skill_params)
    |> assign(:candidates_user, user)
    |> assign(:coordination, coordination)
    |> assign_coordination_form(changeset)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("validate_coordination", %{"coordination" => coordination_params}, socket) do
    changeset =
      socket.assigns.coordination
      |> Coordination.changeset(coordination_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_coordination_form(socket, changeset)}
  end

  def handle_event("open", %{"user" => user_id, "skill_params" => skill_params}, socket) do
    user = UserSearches.get_user_by_id_with_job_profile_and_skill_score(user_id, skill_params)

    skill_params =
      skill_params
      |> Enum.map(&(Enum.map(&1, fn {k, v} -> {String.to_atom(k), v} end) |> Enum.into(%{})))

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
        {:noreply, assign(socket, :candidate_error, "採用調整候補者の上限は４名です")}

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

  def handle_event("decision", %{"decision" => "cancel_interview", "reason" => reason}, socket) do
    {:ok, _coordination} =
      Recruits.update_interview(socket.assigns.interview, %{
        status: :cancel_interview,
        cancel_reason: reason
      })

    Recruits.send_interview_cancel_notification_mails(socket.assigns.interview.id)

    {:noreply, push_navigate(socket, to: socket.assigns.patch)}
  end

  def handle_event(
        "create_coordination",
        %{"coordination" => coordination_params},
        %{
          assigns: %{
            skill_params: skill_params,
            users: users,
            current_user: recruiter,
            interview_id: intervie_id
          }
        } = socket
      ) do
    candidates_user = socket.assigns.candidates_user |> List.first()

    coordination_params =
      Map.merge(coordination_params, %{
        "skill_panel_name" => gen_coordination_name(skill_params),
        "desired_income" => candidates_user.desired_income,
        "skill_params" => Jason.encode!(skill_params),
        "coordination_members" => Enum.map(users, &%{"user_id" => &1.id}),
        "recruiter_user_id" => recruiter.id,
        "candidates_user_id" => candidates_user.id
      })

    case Recruits.create_coordination(coordination_params) do
      {:ok, coordination} ->
        Recruits.get_interview!(intervie_id)
        |> Recruits.update_interview(%{status: :completed_interview})

        preloaded_coordination =
          Recruits.get_coordination_with_member_users!(coordination.id, recruiter.id)

        # 追加したメンバー全員に可否メールを送信する。
        send_acceptance_mails(preloaded_coordination, recruiter)

        {:noreply, redirect(socket, to: ~p"/recruits/coordinations")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_coordination_form(socket, changeset)}
    end
  end

  defp send_acceptance_mails(coordination, recruiter) do
    coordination.coordination_members
    |> Enum.each(fn member ->
      Recruits.deliver_acceptance_coordination_email_instructions(
        recruiter,
        member.user,
        member,
        &url(~p"/recruits/coordinations/member/#{&1}")
      )
    end)
  end

  defp id_duplidated_user?(users, user) do
    users |> Enum.find(fn u -> user.id == u.id end) |> is_nil() |> then(&(!&1))
  end

  defp assign_coordination_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :coordination_form, to_form(changeset))
  end

  defp gen_coordination_name(skill_params) do
    skill_params
    |> List.first()
    |> Map.get(:skill_panel)
    |> SkillPanels.get_skill_panel!()
    |> Map.get(:name)
  end
end
