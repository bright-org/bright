defmodule BrightWeb.RecruitCoordinationLive.Index do
  use BrightWeb, :live_view

  alias Bright.Recruits
  alias Bright.UserProfiles
  import BrightWeb.BrightCoreComponents, only: [elapsed_time: 1]
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="coordination_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">
        <h4 class="text-start">採用選考の状況</h4>
        <li :if={Enum.count(@coordinations) == 0} class="flex">
          <div class="text-left flex items-center text-base py-4 flex-1 mr-2">
            選考中の採用はありません
          </div>
        </li>
        <%= for coordination <- @coordinations do %>
          <% icon_path = coordination.candidates_user.user_profile.icon_file_path %>
          <li class="flex my-5">
            <.link
               patch={~p"/recruits/coordinations/#{coordination.id}"}
              class="cursor-pointer hover:opacity-70 text-left flex items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate"
            >
              <div class="flex flex-col">
                <img
                  src={UserProfiles.icon_url(icon_path)}
                  class="object-cover h-12 w-12 rounded-full mr-2"
                  alt=""
                />
                <span><%= coordination.candidates_user.name %></span>
              </div>
              <div class="flex-1">
                <span><%= if coordination.skill_panel_name == nil, do: "スキルパネルデータなし", else: coordination.skill_panel_name %></span>
                <br />
                <span class="text-brightGray-300">
                <%= NaiveDateTime.to_date(coordination.inserted_at) %>
                希望年収:<%= coordination.desired_income %>
                </span>
              </div>

              <span class="flex-1">
                <%= Gettext.gettext(BrightWeb.Gettext, to_string(coordination.status)) %>
              </span>
              <span class="w-24">
                <.elapsed_time inserted_at={coordination.updated_at} />
              </span>
            </.link>
          </li>
        <% end %>
      </div>
    </div>

    <div id="coordination_member_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">
        <h4 class="text-start">採用選考依頼</h4>
        <li :if={Enum.count(@coordination_members) == 0} class="flex">
          <div class="text-left flex items-center text-base py-4 flex-1 mr-2">
            採用選考の依頼はありません
          </div>
        </li>
        <%= for member <- @coordination_members do %>
        <% icon_path = member.coordination.candidates_user.user_profile.icon_file_path %>
        <% recruiter = member.coordination.recruiter_user %>
          <li class="flex my-5">
            <.link
               patch={~p"/recruits/coordinations/member/#{member.id}"}
              class="cursor-pointer hover:opacity-70 text-left flex flex-wrap items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate"
            >
              <div class="flex flex-col mr-4">
                <img
                  src={UserProfiles.icon_url(recruiter.user_profile.icon_file_path)}
                  class="object-cover h-12 w-12 rounded-full ml-2"
                  alt=""
                />
                <span><%= recruiter.name %></span>
              </div>

              <div class="flex flex-col">
                <img
                  src={UserProfiles.icon_url(icon_path)}
                  class="object-cover h-12 w-12 rounded-full mr-2"
                  alt=""
                />
                <span>
                  <%= member.coordination.candidates_user.name %>
                </span>
              </div>
              <div class="flex-1">
                <span><%= if member.coordination.skill_panel_name == nil, do: "スキルパネルデータなし", else: member.coordination.skill_panel_name %></span>
                <br />
                <span class="text-brightGray-300">
                  <%= NaiveDateTime.to_date(member.inserted_at) %>
                  希望年収:<%= member.coordination.desired_income %>
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

    <div id="coordination_member_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">
        <h4 class="text-start">選考結果</h4>
        <li :if={Enum.count(@acceptances) + Enum.count(@waiting_acceptances) + Enum.count(@acceptance_members)== 0} class="flex">
          <div class="text-left flex items-center text-base py-4 flex-1 mr-2">
            未返答の選考結果はありません
          </div>
        </li>
        <%= for acceptance <- @acceptances do %>
        <% icon_path = acceptance.recruiter_user.user_profile.icon_file_path %>
          <li class="flex my-5">
            <.link
               patch={~p"/recruits/coordinations/acceptance/#{acceptance.id}"}
              class="cursor-pointer hover:opacity-70 text-left flex flex-wrap items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate"
            >
              <div class="flex flex-col mr-4">
                <img
                  src={UserProfiles.icon_url(icon_path)}
                  class="object-cover h-12 w-12 rounded-full mx-2"
                  alt=""
                />
                <span>
                  <%= acceptance.recruiter_user.name %>
                </span>
              </div>
              <span class="flex-1">
                <%= Gettext.gettext(BrightWeb.Gettext, to_string(acceptance.status)) %>
              </span>
              <span class="w-24">
                <.elapsed_time inserted_at={acceptance.updated_at} />
              </span>
            </.link>
          </li>
        <% end %>
        <%= for coordination <- @waiting_decision do %>
          <% icon_path = coordination.candidates_user.user_profile.icon_file_path %>
          <li class="flex my-5">
            <.link
               patch={~p"/recruits/coordinations/#{coordination.id}"}
              class="cursor-pointer hover:opacity-70 text-left flex items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate"
            >
              <div class="flex flex-col mr-4">
                <img
                  src={UserProfiles.icon_url(icon_path)}
                  class="object-cover h-12 w-12 rounded-full mx-2"
                  alt=""
                />
                <span><%= coordination.candidates_user.name %></span>
              </div>
              <div class="flex-1">
                <span><%= if coordination.skill_panel_name == nil, do: "スキルパネルデータなし", else: coordination.skill_panel_name %></span>
                <br />
                <span class="text-brightGray-300">
                <%= NaiveDateTime.to_date(coordination.inserted_at) %>
                希望年収:<%= coordination.desired_income %>
                </span>
              </div>

              <span class="flex-1">
                <%= Gettext.gettext(BrightWeb.Gettext, to_string(coordination.status)) %>
              </span>
              <span class="w-24">
                <.elapsed_time inserted_at={coordination.updated_at} />
              </span>
            </.link>
          </li>
        <% end %>

        <%= for employment <- @waiting_acceptances do %>
        <% icon_path = employment.candidates_user.user_profile.icon_file_path %>
          <li class="flex my-5">
            <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate" >
              <div class="flex flex-col mr-4">
                <img
                  src={UserProfiles.icon_url(icon_path)}
                  class="object-cover h-12 w-12 rounded-full mx-2"
                  alt=""
                />
                <span><%= employment.candidates_user.name %></span>
              </div>
              <div class="flex-1">
                <span><%= if employment.skill_panel_name == nil, do: "スキルパネルデータなし", else: employment.skill_panel_name %></span>
                <br />
                <span class="text-brightGray-300">
                <%= NaiveDateTime.to_date(employment.inserted_at) %>
                提示年収:<%= employment.income %>
                </span>
              </div>
            <span class="flex-1">
              <%= Gettext.gettext(BrightWeb.Gettext, to_string(employment.status)) %>
            </span>
            <span class="w-24">
              <.elapsed_time inserted_at={employment.updated_at} />
            </span>
            </div>
          </li>
        <% end %>

        <%= for member <- @acceptance_members do %>
        <% icon_path = member.coordination.candidates_user.user_profile.icon_file_path %>
        <% recruiter = member.coordination.recruiter_user %>
          <li class="flex my-5">
          <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate" >
              <div class="flex flex-col mr-4 text-base">
                <img
                  src={UserProfiles.icon_url(recruiter.user_profile.icon_file_path)}
                  class="object-cover h-12 w-12 rounded-full mx-2"
                  alt=""
                />
                <span><%= recruiter.name %></span>
              </div>

              <div class="flex flex-col">
                <img
                  src={UserProfiles.icon_url(icon_path)}
                  class="object-cover h-12 w-12 rounded-full"
                  alt=""
                />
                <span>
                  <%= member.coordination.candidates_user.name %>
                </span>
              </div>
              <div class="flex-1">
                <span><%= if member.coordination.skill_panel_name == nil, do: "スキルパネルデータなし", else: member.coordination.skill_panel_name %></span>
                <br />
                <span class="text-brightGray-300">
                  <%= NaiveDateTime.to_date(member.inserted_at) %>
                  希望年収:<%= member.coordination.desired_income %>
                </span>
              </div>
              <span class="flex-1">
                <%= Gettext.gettext(BrightWeb.Gettext, to_string(member.coordination.status)) %>
              </span>
              <span class="flex-1">
                <%= Gettext.gettext(BrightWeb.Gettext, to_string(member.decision)) %>
              </span>
              <span class="w-24">
                <.elapsed_time inserted_at={member.updated_at} />
              </span>
            </div>
          </li>
        <% end %>
      </div>
    </div>


    <.bright_modal :if={@live_action in [:show_coordination]} id="coordination-modal" show on_cancel={JS.patch(~p"/recruits/coordinations")}>
      <.live_component
        module={BrightWeb.RecruitCoordinationLive.EditComponent}
        id="coordination_modal"
        title={@page_title}
        action={@live_action}
        coordination_id={@coordination.id}
        current_user={@current_user}
        patch={~p"/recruits/coordinations"}
        return_to={~p"/recruits/coordinations"}
      />
    </.bright_modal>

    <.bright_modal :if={@live_action in [:show_member]} id="coordination-member-modal" show on_cancel={JS.patch(~p"/recruits/coordinations")}>
      <.live_component
        module={BrightWeb.RecruitCoordinationLive.EditMemberComponent}
        id="coordination_member_modal"
        title={@page_title}
        action={@live_action}
        coordination_member={@coordination_member}
        current_user={@current_user}
        patch={~p"/recruits/coordinations"}
      />
    </.bright_modal>

    <.bright_modal :if={@live_action in [:employment_notification]} id="employment-notification-modal" show on_cancel={JS.patch(~p"/recruits/coordinations")}>
      <.live_component
        module={BrightWeb.RecruitEmploymentLive.CreateComponent}
        id="employment_notification_modal"
        title={@page_title}
        action={@live_action}
        coordination_id={@coordination.id}
        current_user={@current_user}
        patch={~p"/recruits/coordinations"}
      />
    </.bright_modal>


    <.bright_modal :if={@live_action in [:show_acceptance]} id="employment-acceptance-modal" show on_cancel={JS.patch(~p"/recruits/coordinations")}>
      <.live_component
        module={BrightWeb.RecruitCoordinationLive.AcceptanceComponent}
        id="employment_acceptance_modal"
        title={@page_title}
        action={@live_action}
        employment_id={@employment_id}
        current_user={@current_user}
        patch={~p"/recruits/coordinations"}
      />
    </.bright_modal>

    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id

    socket
    |> assign(:page_title, "採用の選考状況")
    |> assign(:coordinations, Recruits.list_coordination(user_id, :waiting_recruit_decision))
    |> assign(:coordination_members, Recruits.list_coordination_members(user_id, :not_answered))
    |> assign(:coordination, nil)
    |> assign(:coordination_member, nil)
    |> assign(:acceptances, Recruits.list_acceptance_employment(user_id))
    |> assign(:waiting_decision, Recruits.list_coordination(user_id, :hiring_decision))
    |> assign(:waiting_acceptances, Recruits.list_employment(user_id, :waiting_response))
    |> assign(:acceptance_members, Recruits.list_coordination_members(user_id, :hiring_decision))
    |> assign(:acceptance, nil)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show_member, %{"id" => id}) do
    user_id = socket.assigns.current_user.id

    socket
    |> assign(:coordination_member, Recruits.get_coordination_member!(id, user_id))
  end

  defp apply_action(socket, :show_acceptance, %{"id" => id}) do
    assign(socket, :employment_id, id)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:coordination, nil)
    |> assign(:coordination_member, nil)
  end

  defp apply_action(socket, _action, %{"id" => id}) do
    user_id = socket.assigns.current_user.id
    coordination = Recruits.get_coordination_with_member_users!(id, user_id)

    action =
      case coordination.status do
        :waiting_recruit_decision -> :show_coordination
        :hiring_decision -> :employment_notification
      end

    socket
    |> assign(:coordination, coordination)
    |> assign(:live_action, action)
  end
end
