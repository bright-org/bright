defmodule BrightWeb.RecruitEmploymentLive.TeamInviteComponent do
  use BrightWeb, :live_component

  alias Bright.Recruits
  alias Bright.UserSearches
  alias Bright.Teams
  alias Bright.Subscriptions
  import BrightWeb.ProfileComponents, only: [profile: 1]
  import Bright.UserProfiles, only: [icon_url: 1]

  def render(assigns) do
    ~H"""
    <div id="team_invite_modal">
      <div class="bg-pureGray-600/90 transition-opacity z-[55]" />
      <div class="overflow-y-auto z-[60]">
        <main class="flex items-center justify-center" role="main">
          <section class="bg-white px-10 py-4 shadow text-sm">
            <h2 class="font-bold text-3xl">
              <span class="before:bg-bgGemSales before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[8px] before:w-9">
                採用決定者のチームへの招待
              </span>
            </h2>
            <div class="flex mt-8">
              <!-- Start 採用候補者と依頼先 -->
              <div class="border-r border-r-brightGray-200 border-dashed mr-8 pr-8 w-[928px]">
                <div>
                  <ul>
                    <div class="flex">
                      <div class="w-[460px]">
                        <.profile
                          user_name={@request.employment.candidates_user.name}
                          title={@request.employment.candidates_user.user_profile.title}
                          icon_file_path={
                            icon_url(@request.employment.candidates_user.user_profile.icon_file_path)
                          }
                        />
                      </div>
                      <div class="ml-8 mt-4 text-xl">
                        <span>報酬：<%= @request.employment.income %>万円</span>
                        <br />
                        <span>
                          雇用形態：<%= Gettext.gettext(
                            BrightWeb.Gettext,
                            to_string(@request.employment.employment_status)
                          ) %>
                        </span>
                      </div>
                    </div>
                    <div class="flex flex-col">
                      <p class="font-bold">稼働按分・工数の扱いに関するメモ・注意点</p>
                      <p class="mt-1 px-5 py-2 border border-brightGray-200 rounded-sm">
                        <%= @request.comment %>
                      </p>
                    </div>
                    <div class="">
                      <.live_component
                        id="user_params_for_employment"
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
                  </ul>
                </div>

                <div class="mt-8">
                  <h3 class="font-bold text-base">ジョイン先チーム</h3>
                  <span class="text-attention-600"><%= Phoenix.HTML.raw(@invite_error) %></span>
                  <div class="bg-white border border-brightGray-200 rounded-md mt-1">
                    <div class="bg-white rounded-md mt-1">
                      <.live_component
                        id="related_team_card"
                        module={BrightWeb.CardLive.ManagingTeamCardComponent}
                        display_user={@current_user}
                      />
                    </div>
                  </div>

                  <div class="flex justify-center gap-x-4 mt-8">
                    <button class="text-sm font-bold py-3 rounded border border-base w-44 h-12">
                      <.link navigate={@return_to}>閉じる</.link>
                    </button>
                    <button
                      class="text-sm font-bold py-3 rounded border border-base w-44 h-12"
                      phx-target={@myself}
                      phx-click="cancel"
                    >
                      チーム招待を行わない
                    </button>
                    <button
                      type="button"
                      class="text-sm font-bold py-3 rounded text-white bg-base w-72"
                      phx-click={JS.push("invite", value: %{team_id: @team_id}, target: @myself)}
                    >
                      チームに招待する
                    </button>
                  </div>
                </div>
              </div>
              <!-- End 採用候補者と依頼先 -->
            </div>
          </section>
        </main>
      </div>
    </div>
    """
  end

  def update(%{team_id: team_id}, socket) do
    {:ok, assign(socket, :team_id, team_id)}
  end

  def update(assigns, socket) do
    request =
      Recruits.get_team_join_request_with_profile!(
        assigns.team_join_request_id,
        assigns.current_user.id
      )

    skill_params =
      request.employment.skill_params
      |> Jason.decode!()
      |> Enum.map(fn s ->
        s
        |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
        |> Enum.into(%{})
      end)

    user =
      UserSearches.get_user_by_id_with_job_profile_and_skill_score(
        request.employment.candidates_user_id,
        skill_params
      )

    socket
    |> assign(assigns)
    |> assign(:request, request)
    |> assign(:skill_params, skill_params)
    |> assign(:candidates_user, user)
    |> assign(:team_id, nil)
    |> assign(:invite_error, "")
    |> then(&{:ok, &1})
  end

  def handle_event("invite", %{"team_id" => nil}, socket) do
    {:noreply, assign(socket, :invite_error, "招待するチームを選択してください")}
  end

  def handle_event("invite", %{"team_id" => team_id}, socket) do
    request = socket.assigns.request
    candidates_user = request.employment.candidates_user
    team = Teams.get_team_with_member!(team_id)
    new_member = [candidates_user | team.users]
    newcomer = [candidates_user]
    admin_user = socket.assigns.current_user

    # members_count: チームメンバー数, 管理者がselected_usersには含まれないため+1をしている
    members_count = Enum.count(team.users) + 1
    sub = Subscriptions.get_user_subscription_user_plan(admin_user.id)

    limit =
      if is_nil(sub), do: 4, else: Subscriptions.get_team_members_limit(sub.subscription_plan)

    cond do
      id_duplidated_user?(team.users, candidates_user) ->
        {:noreply, assign(socket, :invite_error, "対象のユーザーは既に追加されています")}

      member_limit?(members_count, limit) ->
        message = member_limit_message(limit)
        {:noreply, assign(socket, :invite_error, message)}

      true ->
        case Teams.update_team_multi(team, %{}, admin_user, newcomer, new_member) do
          {:ok, team, [member_user_attr | _]} ->
            Teams.deliver_invitation_email_instructions(
              admin_user,
              candidates_user,
              team,
              member_user_attr.base64_encoded_token,
              &url(~p"/teams/invitation_confirm/#{&1}")
            )

            {:ok, _request} = Recruits.update_team_join_request(request, %{status: :invited})

            socket
            |> put_flash(:info, "チームに招待しました")
            |> redirect(to: ~p"/recruits/employments")
            |> then(&{:noreply, &1})

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, changeset)}
        end
    end
  end

  def handle_event("cancel", _params, socket) do
    request = socket.assigns.request

    {:ok, _request} =
      Recruits.update_team_join_request(request, %{
        status: :cancel
      })

    {:noreply, push_navigate(socket, to: ~p"/recruits/employments")}
  end

  defp id_duplidated_user?(users, user) do
    users |> Enum.find(fn u -> user.id == u.id end) |> is_nil() |> then(&(!&1))
  end

  defp member_limit?(members_count, limit) do
    members_count >= limit
  end

  defp member_limit_message(limit) do
    "現在のプランでは、メンバーは#{limit}名まで（管理者含む）が上限です<br /><br />「アップグレード」ボタンから上位プランをご購入いただくと<br />メンバー数を増やせます"
  end
end
