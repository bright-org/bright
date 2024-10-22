defmodule BrightWeb.RecruitInterviewLive.Index do
  use BrightWeb, :live_view

  alias Bright.Recruits
  alias Bright.UserProfiles
  alias Bright.Teams
  import BrightWeb.BrightCoreComponents, only: [elapsed_time: 1]
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="interview_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">
        <h4 class="text-start">面談打診の状況</h4>
        <li :if={Enum.count(@interviews) == 0} class="flex">
          <div class="text-left flex items-center text-base py-4 flex-1 mr-2">
            打診中の面談はありません
          </div>
        </li>
        <%= for interview <- @interviews do %>
          <% icon_path =
            if interview.status == :ongoing_interview or
                 Enum.member?(@team_members, interview.candidates_user_id),
               do: interview.candidates_user.user_profile.icon_file_path,
               else: nil %>
          <li class="flex my-5">
            <.link
              patch={~p"/recruits/interviews/#{interview.id}"}
              class="cursor-pointer hover:filter hover:brightness-[80%] text-left flex items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate"
            >
              <div class="flex flex-col">
                <img
                  src={UserProfiles.icon_url(icon_path)}
                  class="object-cover h-12 w-12 rounded-full mr-2"
                  alt=""
                />
                <span :if={Enum.member?(@team_members, interview.candidates_user_id)}>
                  <%= interview.candidates_user.name %>
                </span>
              </div>
              <div class="flex-1">
                <span>
                  <%= if interview.skill_panel_name == nil,
                    do: "スキルパネルデータなし",
                    else: interview.skill_panel_name %>
                </span>
                <br />
                <span class="text-brightGray-300">
                  <%= NaiveDateTime.to_date(interview.inserted_at) %> 希望年収:<%= interview.desired_income %>
                </span>
              </div>

              <span class="flex-1">
                <%= Gettext.gettext(BrightWeb.Gettext, to_string(interview.status)) %>
              </span>
              <span class="w-24">
                <.elapsed_time inserted_at={interview.updated_at} />
              </span>
            </.link>
          </li>
        <% end %>
      </div>
    </div>

    <div
      id="interview_member_container"
      class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5"
    >
      <div class="text-sm font-medium text-center">
        <h4 class="text-start">面談同席依頼</h4>
        <li :if={Enum.count(@interview_members) == 0} class="flex">
          <div class="text-left flex items-center text-base py-4 flex-1 mr-2">
            面談同席の依頼はありません
          </div>
        </li>
        <%= for member <- @interview_members do %>
          <% icon_path =
            if Enum.member?(@team_members, member.interview.candidates_user_id),
              do: member.interview.candidates_user.user_profile.icon_file_path,
              else: nil %>
          <% recruiter = member.interview.recruiter_user %>
          <li class="flex my-5">
            <.link
              patch={~p"/recruits/interviews/member/#{member.id}"}
              class="cursor-pointer hover:opacity-70 text-left flex flex-wrap items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate"
            >
              <div class="flex flex-col mt-4 mr-4">
                <img
                  src={UserProfiles.icon_url(recruiter.user_profile.icon_file_path)}
                  class="object-cover h-10 w-10 rounded-full ml-4"
                  alt=""
                />
                <span>
                  <%= recruiter.name %>
                </span>
              </div>

              <div class="flex flex-col">
                <img
                  src={UserProfiles.icon_url(icon_path)}
                  class="object-cover h-12 w-12 rounded-full mr-2"
                  alt=""
                />
                <span :if={Enum.member?(@team_members, member.interview.candidates_user_id)}>
                  <%= member.interview.candidates_user.name %>
                </span>
              </div>
              <div class="flex-1">
                <span>
                  <%= if member.interview.skill_panel_name == nil,
                    do: "スキルパネルデータなし",
                    else: member.interview.skill_panel_name %>
                </span>
                <br />
                <span class="text-brightGray-300">
                  <%= NaiveDateTime.to_date(member.inserted_at) %> 希望年収:<%= member.interview.desired_income %>
                </span>
              </div>

              <span class="flex-1">
                <%= Gettext.gettext(BrightWeb.Gettext, to_string(member.decision)) %>
              </span>
              <span class="w-24">
                <.elapsed_time inserted_at={member.updated_at} />
              </span>
            </.link>
          </li>
        <% end %>
      </div>
    </div>

    <.bright_modal
      :if={@live_action in [:show_interview]}
      id="interview-modal"
      show
      on_cancel={JS.patch(~p"/recruits/interviews")}
    >
      <.live_component
        module={BrightWeb.RecruitInterviewLive.EditComponent}
        id="interview_modal"
        title={@page_title}
        action={@live_action}
        interview={@interview}
        current_user={@current_user}
        patch={~p"/recruits/interviews"}
      />
    </.bright_modal>

    <.bright_modal
      :if={@live_action in [:confirm_interview]}
      id="interview-confirm-modal"
      show
      on_cancel={JS.patch(~p"/recruits/interviews")}
    >
      <.live_component
        module={BrightWeb.RecruitInterviewLive.ConfirmComponent}
        id="interview_member_modal"
        title={@page_title}
        action={@live_action}
        interview_id={@interview.id}
        current_user={@current_user}
        patch={~p"/recruits/interviews"}
      />
    </.bright_modal>

    <.bright_modal
      :if={@live_action in [:create_coordination]}
      id="corrdination-create-modal"
      show
      on_cancel={JS.patch(~p"/recruits/interviews")}
    >
      <.live_component
        :if={@current_user}
        id="coordination_modal"
        module={BrightWeb.RecruitCoordinationLive.CreateComponent}
        current_user={@current_user}
        interview_id={@interview.id}
        patch={~p"/recruits/interviews"}
      />
    </.bright_modal>

    <.bright_modal
      :if={@live_action in [:show_member]}
      id="interview-member-modal"
      show
      on_cancel={JS.patch(~p"/recruits/interviews")}
    >
      <.live_component
        module={BrightWeb.RecruitInterviewLive.EditMemberComponent}
        id="interview_member_modal"
        title={@page_title}
        action={@live_action}
        interview_member={@interview_member}
        current_user={@current_user}
        patch={~p"/recruits/interviews"}
      />
    </.bright_modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket
    |> assign(:page_title, "面談の打診状況")
    |> assign(:interviews, Recruits.list_interview(user.id, :not_complete))
    |> assign(:interview_members, Recruits.list_interview_members(user.id, :not_answered))
    |> assign(:interview, nil)
    |> assign(:interview_member, nil)
    |> assign(:team_members, Teams.list_user_ids_related_team_by_user(user))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show_member, %{"id" => id}) do
    user_id = socket.assigns.current_user.id

    socket
    |> assign(:interview_member, Recruits.get_interview_member!(id, user_id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:interview, nil)
    |> assign(:interview_member, nil)
  end

  defp apply_action(socket, _action, %{"id" => id}) do
    user_id = socket.assigns.current_user.id
    interview = Recruits.get_interview_with_member_users!(id, user_id)

    action =
      case interview.status do
        :waiting_decision -> :show_interview
        :consume_interview -> :confirm_interview
        :ongoing_interview -> :create_coordination
      end

    socket
    |> assign(:interview, interview)
    |> assign(:live_action, action)
  end
end
