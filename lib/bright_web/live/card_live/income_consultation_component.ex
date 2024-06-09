defmodule BrightWeb.CardLive.IncomeConsultationComponent do
  @moduledoc """
  　関わっているチームの上長カードコンポーネント

  - display_user チーム一覧の取得対象となるユーザー. 匿名考慮がされていないため原則current_user
  - over_ride_on_card_row_click_target カードコンポーネント内の行クリック時のハンドラを呼び出し元のハンドラで実装するか否か falseの場合、本実装デフォルトの挙動(チームIDのみ指定してのチームスキル分析への遷移)を実行する

  ## Examples
    <.live_component
      id="income_consultation"
      module={BrightWeb.CardLive.IncomeConsultationComponent}
      current_user={@current_user}
      skill_panel_id={@skill_panel.id}
    />
  """
  use BrightWeb, :live_component

  import BrightWeb.TeamComponents, only: [get_team_icon_path: 1]

  alias Bright.Teams
  alias Bright.UserSearches
  alias Bright.SkillPanels
  alias Bright.Chats
  alias Bright.Recruits
  alias Bright.Recruits.Interview

  @impl true
  def render(assigns) do
    ~H"""
    <div id="income_consultation_modal">
      <div class="bg-pureGray-600/90 transition-opacity z-[55]" />
      <div class="overflow-y-auto z-[60]">
        <main class="flex items-center justify-center " role="main">
          <section class="bg-white px-10 py-8 shadow text-sm w-full">
            <div class="py-1">
              <h3>報酬アップを相談する</h3>
              <div class="py-1">報酬アップを相談する先となるチームのリーダーを選択してください</div>
              <div class="pt-3 pb-1 px-6 lg:h-[226px] lg:w-[500px]">
                <%= if length(@team_readers) > 0 do %>
                  <ul class="flex gap-y-2 flex-col">
                    <%= for team_params <- @team_readers do %>
                      <li
                        phx-click="start_consultation"
                        phx-target={@myself}
                        phx-value-team_admin_user_id={team_params.admin_user.user.id}
                        class="h-[35px] text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded cursor-pointer"
                      >
                        <span :if={is_nil(team_params.is_star)}></span>
                        <%= if team_params.is_star do %>
                          <span class="material-icons text-brightGreen-300">star</span>
                        <% else %>
                          <span class="material-icons text-brightGray-100">star</span>
                        <% end %>
                        <img src={get_team_icon_path(team_params.team_type)} class="ml-2 mr-2" />
                        <span class="max-w-[160px] lg:max-w-[280px] truncate">
                          <%= team_params.name %>
                        </span>
                        <span class="max-w-[160px] lg:max-w-[280px] truncate px-3">
                          <%= team_params.admin_user.user.name %>
                        </span>
                      </li>
                    <% end %>
                  </ul>
                <% else %>
                  <% # 表示内容がないときの表示 %>
                  <ul>
                    対象のチームのリーダーがいません
                  </ul>
                <% end %>
              </div>
            </div>
          </section>
        </main>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{current_user: user} = assigns, socket) do
    team_readers =
      Teams.list_joined_teams_superior_by_user_id(user.id)
      |> convert_team_params_from_team_superior()

    socket
    |> assign(assigns)
    |> assign(:team_readers, team_readers)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event(
        "start_consultation",
        %{"team_admin_user_id" => team_admin_user_id},
        %{assigns: %{current_user: user, skill_panel_id: skill_panel_id}} = socket
      ) do
    skill_params = [%{"career_field" => "1on1", "skill_panel" => skill_panel_id}]

    interview =
      case Recruits.get_interview(team_admin_user_id, user.id) do
        %Interview{} = interview ->
          if interview.status in [:cancel_interview, :completed_interview, :dismiss_interview, :close_chat],
            do: create_interview(skill_params, team_admin_user_id, user),
            else: interview

        nil ->
          create_interview(skill_params, team_admin_user_id, user)
      end

    chat =
      Chats.get_or_create_chat(
        interview.recruiter_user_id,
        interview.candidates_user_id,
        interview.id,
        "recruit",
        [
          %{user_id: interview.recruiter_user_id},
          %{user_id: interview.candidates_user_id}
        ]
      )

    {:noreply, push_navigate(socket, to: ~p"/recruits/chats/#{chat.id}")}
  end

  defp create_interview(skill_params, team_admin_user_id, user) do
    skill_params =
      skill_params
      |> Enum.map(
        &(Enum.map(&1, fn {k, v} -> {String.to_atom(k), v} end)
          |> Enum.into(%{}))
      )

    candidates_user =
      UserSearches.get_user_by_id_with_job_profile_and_skill_score(user.id, skill_params)
      |> List.first()

    interview_params = %{
      "status" => :one_on_one,
      "skill_panel_name" => gen_interview_name(skill_params),
      "desired_income" => candidates_user.desired_income,
      "skill_params" => Jason.encode!(skill_params),
      "interview_members" => [],
      "recruiter_user_id" => team_admin_user_id,
      "candidates_user_id" => user.id
    }

    {:ok, interview} = Recruits.create_interview(interview_params)

    interview
  end

  def convert_team_params_from_team_superior(team_member_users) do
    team_member_users
    |> Enum.map(fn team_member_user ->
      %{
        team_id: team_member_user.team.id,
        name: team_member_user.team.name,
        is_star: team_member_user.is_star,
        is_admin: team_member_user.is_admin,
        team_type: Teams.get_team_type_by_team(team_member_user.team),
        admin_user:
          team_member_user.team.member_users
          |> Enum.filter(fn x -> x.is_admin end)
          |> List.first()
      }
    end)
  end

  defp gen_interview_name(skill_params) do
    skill_params
    |> List.first()
    |> Map.get(:skill_panel)
    |> SkillPanels.get_skill_panel!()
    |> Map.get(:name)
  end
end
