defmodule BrightWeb.RecruitEmploymentLive.Index do
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
        <h4 class="text-start">採用の状況</h4>
        <li :if={Enum.count(@employments) == 0} class="flex">
          <div class="text-left flex items-center text-base py-4 flex-1 mr-2">
            進行中の採用はありません
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
                <CardListComponents.elapsed_time inserted_at={employment.updated_at} />
              </span>
            </.link>
          </li>
        <% end %>
      </div>
    </div>

    <div id="coordination_member_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">
      </div>
    </div>

    <.bright_modal :if={@live_action in [:show_employment]} id="employment-modal" show on_cancel={JS.patch(~p"/recruits/employments")}>
      <.live_component
        module={BrightWeb.RecruitEmploymentLive.EmploymentComponent}
        id="employment_modal"
        employment={@employment}
        current_user={@current_user}
        return_to={~p"/recruits/employments"}
      />
    </.bright_modal>

    <.bright_modal :if={@live_action in [:show_acceptance]} id="acceptance-modal" show on_cancel={JS.patch(~p"/recruits/employments")}>
      <.live_component
        module={BrightWeb.RecruitEmploymentLive.AcceptanceComponent}
        id="acceptance_modal"
        employment={@employment}
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
    |> assign(:page_title, "採用決定者チームジョイン")
    |> assign(:employments, Recruits.list_employment(user_id))
    |> assign(:employment, nil)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show_acceptance, %{"id" => id}) do
    user_id = socket.assigns.current_user.id

    socket
    |> assign(:employment, Recruits.get_employment_acceptance!(id, user_id))
  end

  defp apply_action(socket, :index, _params), do: assign(socket, :employment, nil)

  defp apply_action(socket, _action, %{"id" => id}) do
    user_id = socket.assigns.current_user.id
    employment = Recruits.get_employment_with_profile!(id, user_id)

    action =
      case employment.status do
        :waiting_response -> :show_employment
        :acceptance_emplyoment -> :show_employment
      end

    socket
    |> assign(:employment, employment)
    |> assign(:live_action, action)
  end
end
