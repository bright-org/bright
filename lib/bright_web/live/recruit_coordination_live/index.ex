defmodule BrightWeb.RecruitCoordinationLive.Index do
  use BrightWeb, :live_view

  alias Bright.Recruits
  alias BrightWeb.CardLive.CardListComponents
  alias Bright.UserProfiles
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="coordination_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">
        <h4 class="text-start">採用検討の状況</h4>
        <li :if={Enum.count(@coordinations) == 0} class="flex">
          <div class="text-left flex items-center text-base py-4 flex-1 mr-2">
            検討中の採用はありません
          </div>
        </li>
        <%= for coordination <- @coordinations do %>
          <% icon_path = coordination.candidates_user.user_profile.icon_file_path %>
          <li class="flex my-5">
            <.link
               patch={~p"/recruits/coordinations/#{coordination.id}"}
              class="cursor-pointer hover:opacity-70 text-left flex items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate"
            >
              <img
                src={UserProfiles.icon_url(icon_path)}
                class="object-cover h-12 w-12 rounded-full mr-2"
                alt=""
              />
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
                <CardListComponents.elapsed_time inserted_at={coordination.updated_at} />
              </span>
            </.link>
          </li>
        <% end %>
      </div>
    </div>

    <div id="coordination_member_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">

    <h4 class="text-start">採用検討依頼</h4>
        <li :if={Enum.count(@coordination_members) == 0} class="flex">
          <div class="text-left flex items-center text-base py-4 flex-1 mr-2">
            採用検討の依頼はありません
          </div>
        </li>
        <%= for member <- @coordination_members do %>
        <% icon_path = member.coordination.candidates_user.user_profile.icon_file_path %>
          <li class="flex my-5">
            <.link
               patch={~p"/recruits/coordinations/member/#{member.id}"}
              class="cursor-pointer hover:opacity-70 text-left flex flex-wrap items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate"
            >
              <img
                src={UserProfiles.icon_url(icon_path)}
                class="object-cover h-12 w-12 rounded-full mr-2"
                alt=""
              />
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
                <CardListComponents.elapsed_time inserted_at={member.updated_at} />
              </span>
            </.link>
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
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id

    socket
    |> assign(:page_title, "採用調整")
    |> assign(:coordinations, Recruits.list_coordination(user_id, :not_complete))
    |> assign(:coordination_members, Recruits.list_coordination_members(user_id, :not_answered))
    |> assign(:coordination, nil)
    |> assign(:coordination_member, nil)
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
        :hiting_decision -> :show_coordination
      end

    socket
    |> assign(:coordination, coordination)
    |> assign(:live_action, action)
  end
end