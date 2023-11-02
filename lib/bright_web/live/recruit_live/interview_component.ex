defmodule BrightWeb.RecruitLive.InterviewComponent do
  use BrightWeb, :live_component

  alias Bright.Accounts
  alias Bright.UserSearches
  alias BrightWeb.BrightCoreComponents, as: BrightCore
  import BrightWeb.ProfileComponents, only: [profile_small_with_remove_button: 1]

  def render(assigns) do
    ~H"""
    <div id="adoption_modal" class="hidden">
      <div class="bg-pureGray-600/90 fixed inset-0 transition-opacity z-[55]" />
      <div class="fixed inset-0 overflow-y-auto z-[60]">
        <main class="flex h-screen items-center justify-center w-screen" role="main">
          <section class="absolute bg-white px-10 py-8 shadow text-sm top-0 w-[1500px]">
            <h2 class="font-bold text-3xl">
              <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">
                面談調整
              </span>
            </h2>

            <div class="flex mt-8">
              <div class="border-r border-r-brightGray-200 border-dashed mr-8 pr-8 w-[860px]">
                <div>
                  <h3 class="font-bold text-base">採用候補者</h3>
                  <.live_component
                    id="user_params"
                    prefix="interview"
                    search={false}
                    module={BrightWeb.SearchLive.SearchResultsComponent}
                    current_user={@current_user}
                    result={@interview_user}
                    skill_params={@skill_params}
                    stock_user_ids={[]}
                  />
                </div>

                <div class="mt-8">
                  <h3 class="font-bold text-base">面談調整依頼先<span class="font-normal">を追加</span></h3>
                  <.live_component
                    id="recruit_card"
                    module={BrightWeb.CardLive.RelatedRecruitUserCardComponent}
                    current_user={@current_user}
                  />
                </div>
              </div>
          <!-- Start 面談調整内容 -->
            <div class="w-[493px]">
              <h3 class="font-bold text-xl">採用調整内容</h3>
                  <div class="bg-brightGray-10 mt-4 rounded-sm px-10 py-6">
                    <dl class="flex flex-wrap w-full">
                      <dt
                        class="font-bold w-[98px] flex items-center mb-10"
                      >
                        依頼者
                      </dt>
                      <dd class="w-[280px] mb-10">
                        なし
                      </dd>

                      <dt class="font-bold w-[98px] mb-10">面談参加<br>候補</dt>
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
                        <label for="point" class="block pr-1">採用候補者の推しポイント・注意点</label>
                      </dt>
                      <dd class="w-[280px] mt-16">
                      <BrightCore.input
                        error_class="ml-[100px] mt-2"
                        label="チーム名"
                        name="text"
                        value="hoge"
                        type="textarea"
                        required
                        rows="5"
                        cols="30"
                        input_class="px-5 py-2 border border-brightGray-100 rounded-sm flex-1 w-full"
                        placeholder="新しいチーム名を入力してください"
                      />
                      </dd>
                    </dl>
                  </div>

                <div class="flex justify-end gap-x-4 mt-16">
                  <button
                    phx-click={JS.hide(to: "#adoption_modal")}
                    class="text-sm font-bold py-3 rounded text-white bg-base w-72"
                  >
                    面談調整を依頼する
                  </button>
                </div>
            </div><!-- End 面談調整内容 -->
          </div>
            <div>
              <button
                class="absolute right-5 top-5 z-10"
                phx-click={JS.hide(to: "#adoption_modal")}
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
    |> assign(:interview_user, [])
    |> assign(:skill_params, %{})
    |> assign(:users, [])
    |> then(&{:ok, &1})
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> then(&{:ok, &1})
  end

  def handle_event("open", %{"user" => user_id, "skill_params" => skill_params}, socket) do
    IO.inspect(skill_params)
    user = UserSearches.get_user_by_id_with_job_profile_and_skill_score(user_id, skill_params)

    skill_params =
      skill_params
      |> Enum.map(&(Enum.map(&1, fn {k, v} -> {String.to_atom(k), v} end) |> Enum.into(%{})))

    socket
    |> assign(:interview_user, user)
    |> assign(:skill_params, skill_params)
    |> then(&{:noreply, &1})
  end

  def handle_event("add_user", %{"name" => name}, socket) do
    user = Accounts.get_user_by_name_or_email(name)
    users = socket.assigns.users ++ [user]
    {:noreply, assign(socket, :users, users)}
  end
end
