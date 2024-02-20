defmodule BrightWeb.RecruitEmploymentLive.EmploymentComponent do
  use BrightWeb, :live_component

  alias Bright.UserSearches
  alias Bright.Accounts
  alias Bright.Recruits
  alias Bright.Recruits.Employment
  alias BrightWeb.BrightCoreComponents, as: BrightCore

  import BrightWeb.ProfileComponents, only: [profile: 1, profile_small_with_remove_button: 1]
  import Bright.UserProfiles, only: [icon_url: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="employment_modal">
      <div class="bg-pureGray-600/90 transition-opacity z-[55]" />
      <div class="overflow-y-auto z-[60]">
        <main class="flex items-center justify-center" role="main">
          <section class="bg-white px-10 py-8 shadow text-sm">
            <h2 class="font-bold text-3xl">
              <span class="before:bg-bgGemSales before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[8px] before:w-9">
                採用決定者のジョイン先確定
              </span>
            </h2>

            <div class="flex mt-8">
              <div class="border-r border-r-brightGray-200 border-dashed mr-8 pr-8 w-[928px]">
                <div>
                  <ul>
                    <div class="flex">
                      <div class="w-[460px]">
                      <.profile
                        user_name={@employment.candidates_user.name}
                        title={@employment.candidates_user.user_profile.title}
                        icon_file_path={icon_url(@employment.candidates_user.user_profile.icon_file_path)}
                      />
                      </div>
                      <div class="ml-8 mt-4 text-xl">
                        <span>報酬：<%= @employment.income %>万円</span><br>
                        <span>雇用形態：<%= Gettext.gettext(BrightWeb.Gettext, to_string(@employment.employment_status)) %></span>
                      </div>
                    </div>
                    <div class="-mt-8">
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
                  <h3 class="font-bold text-base">ジョイン先チーム管理者<span class="font-normal">を選んでください</span></h3>
                  <.live_component
                    id="employment_card"
                    module={BrightWeb.CardLive.RelatedTeamOwnerCardComponent }
                    current_user={@current_user}
                    target="#employment_modal"
                    event="add_user"
                  />
                  <span class="text-attention-600"><%= @candidate_error %></span>
                </div>
                </div>
                <!-- Start ジョイン先チーム調整内容 -->
                <div class="w-[493px]">
                  <h3 class="font-bold text-xl">ジョイン先チーム調整内容</h3>
                  <.form
                    for={@form}
                    id="employment_form"
                    phx-target={@myself}
                    phx-submit="create"
                    phx-change="validate"
                  >
                    <div class="bg-brightGray-10 mt-4 rounded-sm px-10 py-6">
                      <dl class="flex flex-wrap w-full">
                      <dt class="font-bold w-[98px] mb-10">ジョイン<br>先チーム<br>管理者</dt>
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
                          <label for="point" class="block pr-1">稼働按分・工数の扱いに関するメモ・注意点</label>
                        </dt>
                        <dd class="w-[280px] mt-16">
                        <BrightCore.input
                          error_class="ml-[100px] mt-2"
                          field={@form[:comment]}
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
                        type="submit"
                        class="text-sm font-bold py-3 rounded text-white bg-base w-72"
                      >
                        候補者のチーム招待を依頼する
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
    |> assign(:users, [])
    |> assign(:skill_params, %{})
    |> assign(:employment, nil)
    |> assign(:candidate_error, "")
    |> then(&{:ok, &1})
  end

  @impl true
  def update(%{employment_id: id, current_user: user} = assigns, socket) do
    employment = Recruits.get_employment_with_profile!(id, user.id)

    skill_params =
      employment.skill_params
      |> Jason.decode!()
      |> Enum.map(fn s ->
        s
        |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
        |> Enum.into(%{})
      end)

    user =
      UserSearches.get_user_by_id_with_job_profile_and_skill_score(
        employment.candidates_user_id,
        skill_params
      )

    changeset = Recruits.change_employment(employment)

    socket
    |> assign(assigns)
    |> assign(:employment, employment)
    |> assign(:skill_params, skill_params)
    |> assign(:candidates_user, user)
    |> assign_form(changeset)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("validate", %{"employment" => employment_params}, socket) do
    changeset =
      socket.assigns.employment
      |> Employment.changeset(employment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("add_user", %{"name" => name}, socket) do
    user = Accounts.get_user_by_name_or_email(name)
    users = socket.assigns.users

    cond do
      id_duplidated_user?(users, user) ->
        {:noreply, assign(socket, :candidate_error, "対象のユーザーは既に追加されています")}

      Enum.count(users) >= 4 ->
        {:noreply, assign(socket, :candidate_error, "ジョイン先チーム管理者の上限は４名です")}

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

  def handle_event("create", %{"employment" => employment_params}, socket) do
    employment = socket.assigns.employment
    users = socket.assigns.users

    employment_params =
      Map.merge(employment_params, %{
        "status" => :requested,
        "team_join_requests" =>
          Enum.map(
            users,
            &%{
              "team_owner_user_id" => &1.id,
              "comment" => employment_params["comment"]
            }
          )
      })

    case Recruits.update_employment(employment, employment_params) do
      {:ok, _coordination} ->
        requests = Recruits.list_team_join_request_by_employment_id(employment.id)
        # 追加したメンバー全員に可否メールを送信する。
        send_request_mails(requests, socket.assigns.current_user)

        {:noreply, redirect(socket, to: ~p"/recruits/employments")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp send_request_mails(requests, recruiter) do
    requests
    |> Enum.each(fn request ->
      Recruits.deliver_team_join_request_email_instructions(
        recruiter,
        request.team_owner_user,
        request,
        &url(~p"/recruits/employments/team_join/#{&1}")
      )
    end)
  end

  defp id_duplidated_user?(users, user) do
    users |> Enum.find(fn u -> user.id == u.id end) |> is_nil() |> then(&(!&1))
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
