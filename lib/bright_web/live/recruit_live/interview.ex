defmodule BrightWeb.RecruitLive.Interview do
  alias Bright.Recruits
  use BrightWeb, :live_view

  alias BrightWeb.CardLive.CardListComponents
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="interview_container" class="bg-white rounded-md my-1 mb-20 lg:my-20 lg:w-3/5 m-auto p-5">
      <div class="text-sm font-medium text-center">
        <li :if={Enum.count(@interviews) == 0} class="flex">
          <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
          調整中の面談はありません
          </div>
        </li>
        <%= for interview <- @interviews do %>
          <li class="flex flex-wrap my-5">
            <.link
               patch={~p"/recruits/interviews/#{interview.id}"}
              class="cursor-pointer hover:opacity-70 text-left flex flex-wrap items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap truncate"
            >
              <span class="material-icons text-lg text-white bg-brightGreen-300 rounded-full flex w-6 h-6 mr-2.5 items-center justify-center">
                person
              </span>
              <span class={"order-3 lg:order-2 flex-1 mr-2 truncate"}>
                <%= Gettext.gettext(BrightWeb.Gettext, to_string(interview.status)) %>
              </span>
              <CardListComponents.elapsed_time inserted_at={interview.updated_at} />
            </.link>
          </li>
        <% end %>

      </div>
    </div>

    <.bright_modal :if={@live_action in [:show]} id="interview-modal" show on_cancel={JS.patch(~p"/recruits/interviews")}>
      <.live_component
        module={BrightWeb.RecruitLive.EditInterviewComponent}
        id="interview_modal"
        title={@page_title}
        action={@live_action}
        interview={@interview}
        current_user={@current_user}
        patch={~p"/recruits/interviews"}
      />
    </.bright_modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "面談調整")
    |> assign(:interviews, Recruits.list_interview())
    |> assign(:interview, nil)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:interview, Recruits.get_interview_with_member_users!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:interview, nil)
  end
end
