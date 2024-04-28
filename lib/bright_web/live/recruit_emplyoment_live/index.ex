defmodule BrightWeb.RecruitEmploymentLive.Index do
  use BrightWeb, :live_view

  alias Bright.Recruits
  alias Bright.UserProfiles
  import BrightWeb.BrightCoreComponents, only: [elapsed_time: 1]
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="employment_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">
        <h4 class="text-start">配属チームの調整状況</h4>
        <li :if={Enum.count(@employments) == 0} class="flex">
          <div class="text-left flex items-center text-base py-4 flex-1 mr-2">
            進行中の配属チームの調整はありません
          </div>
        </li>
        <%= for employment <- @employments do %>
          <% icon_path = employment.candidates_user.user_profile.icon_file_path %>
          <li class="flex my-5">
            <.link
               patch={~p"/recruits/employments/#{employment.id}"}
              class="cursor-pointer hover:opacity-70 text-left flex items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate"
            >
              <img
                src={UserProfiles.icon_url(icon_path)}
                class="object-cover h-12 w-12 rounded-full mr-2"
                alt=""
              />
              <div class="flex-1">
                <span><%= employment.candidates_user.name %></span>
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
            </.link>
          </li>
        <% end %>
      </div>
    </div>

    <div id="team_join_request_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">
        <h4 class="text-start">配属チームの調整の依頼</h4>
        <li :if={Enum.count(@team_join_requests) == 0} class="flex">
          <div class="text-left flex items-center text-base py-4 flex-1 mr-2">
            進行中の配属チームの調整はありません
          </div>
        </li>
        <%= for request <- @team_join_requests do %>
          <% icon_path = request.employment.recruiter_user.user_profile.icon_file_path %>
          <li class="flex my-5">
            <.link
               patch={~p"/recruits/employments/team_join/#{request.id}"}
              class="cursor-pointer hover:opacity-70 text-left flex items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate"
            >
              <img
                src={UserProfiles.icon_url(icon_path)}
                class="object-cover h-12 w-12 rounded-full mr-2"
                alt=""
              />
              <div class="flex-1">
                <span><%= request.employment.recruiter_user.name %></span>
              </div>

              <span class="flex-1">
                <%= Gettext.gettext(BrightWeb.Gettext, to_string(request.status)) %>
              </span>
              <span class="w-24">
                <.elapsed_time inserted_at={request.updated_at} />
              </span>
            </.link>
          </li>
        <% end %>
      </div>
    </div>

    <.bright_modal :if={@live_action in [:team_join]} id="employment-modal" show on_cancel={JS.patch(~p"/recruits/employments")}>
      <.live_component
        module={BrightWeb.RecruitEmploymentLive.EmploymentComponent}
        id="employment_modal"
        employment_id={@employment_id}
        current_user={@current_user}
        return_to={~p"/recruits/employments"}
      />
    </.bright_modal>

    <.bright_modal :if={@live_action in [:team_invite]} id="team-join-modal" show on_cancel={JS.patch(~p"/recruits/employments")}>
      <.live_component
        module={BrightWeb.RecruitEmploymentLive.TeamInviteComponent}
        id="team_join_modal"
        team_join_request_id={@team_join_request_id}
        current_user={@current_user}
        return_to={~p"/recruits/employments"}
      />
    </.bright_modal>

    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id

    socket
    |> assign(:page_title, "配属チームの調整状況")
    |> assign(:employments, Recruits.list_employment(user_id))
    |> assign(:team_join_requests, Recruits.list_team_join_request(user_id))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params), do: socket

  defp apply_action(socket, :team_join, %{"id" => id}) do
    assign(socket, :employment_id, id)
  end

  defp apply_action(socket, :team_invite, %{"id" => id}) do
    assign(socket, :team_join_request_id, id)
  end
end
