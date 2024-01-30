defmodule BrightWeb.CardLive.RelatedTeamOwnerCardComponent do
  @moduledoc """
  Related Recruit Users Card Components
  """
  use BrightWeb, :live_component
  import BrightWeb.ProfileComponents
  import BrightWeb.TabComponents
  import BrightWeb.TeamComponents

  alias Bright.Teams
  alias Bright.UserProfiles

  @tabs [
    {"team", "所属チーム"},
    {"supporter_teams", "採用・育成チーム"},
    {"supportee_teams", "採用・育成支援先"}
  ]

  @page_size 4

  @impl true
  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <.tab
        id={"related-team-owner-#{@id}"}
        tabs={@tabs}
        selected_tab={@selected_tab}
        target={@myself}
        page={@page}
        total_pages={@total_pages}
      >
        <div class="pt-3 pb-1 px-6 lg:min-h-[192px]">
          <%= if length(@user_profiles) == 0 do %>
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
              <%= Enum.into(@tabs, %{}) |> Map.get(@selected_tab) %>にチーム管理者はいません
              </div>
            </li>
          <% else %>
            <ul class="flex gap-y-2 flex-col">
              <%= for user_profile <- @user_profiles do %>
                <div class="flex hover:bg-brightGray-50 hover:cursor-pointer">
                  <.profile_small
                    user_name={user_profile.user_name}
                    title={user_profile.title}
                    icon_file_path={user_profile.icon_file_path}
                    encrypt_user_name={user_profile.encrypt_user_name}
                    click_target={@target}
                    click_event={@event}
                  />
                  <.team_small
                    id={user_profile.team.team_id}
                    team_params={user_profile.team}
                  />
                </div>
              <% end %>
            </ul>
          <% end %>
        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket
    |> assign(:current_user, nil)
    |> assign(:tabs, @tabs)
    |> assign(:selected_tab, "team")
    |> assign(:user_profiles, [])
    |> assign(:page, 1)
    |> assign(:total_pages, 0)
    |> assign(:page_size, @page_size)
    |> then(&{:ok, &1})
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign(:page, 1)
    |> assign(:selected_tab, "team")
    |> assign_selected_card("team")
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("tab_click", %{"tab_name" => tab}, socket) do
    socket
    |> assign(:page, 1)
    |> assign(:selected_tab, tab)
    |> assign_selected_card(tab)
    |> then(&{:noreply, &1})
  end

  def handle_event("previous_button_click", _params, socket) do
    page = socket.assigns.page - 1
    page = if page < 1, do: 1, else: page

    socket =
      socket
      |> assign(:page, page)
      |> assign_selected_card(socket.assigns.selected_tab)

    {:noreply, socket}
  end

  def handle_event("next_button_click", _params, socket) do
    socket =
      socket
      |> assign(:page, socket.assigns.page + 1)
      |> assign_selected_card(socket.assigns.selected_tab)

    {:noreply, socket}
  end

  defp assign_selected_card(socket, tab) do
    page =
      list_teams_owner_by_user_id(tab, socket.assigns.current_user.id, %{
        page: socket.assigns.page,
        page_size: @page_size
      })

    member_and_users =
      page.entries
      |> Enum.map(fn %{user: user, team: team} ->
        %{
          user_name: user.name,
          title: user.user_profile.title,
          icon_file_path: UserProfiles.icon_url(user.user_profile.icon_file_path),
          encrypt_user_name: "",
          team: %{
            team_id: team.id,
            is_star: nil,
            is_admin: false,
            name: team.name,
            team_type: Teams.get_team_type_by_team(team)
          }
        }
      end)

    socket
    |> assign(:user_profiles, member_and_users)
    |> assign(:total_pages, page.total_pages)
  end

  defp list_teams_owner_by_user_id("team", user_id, page_params) do
    Teams.list_joined_teams_owner_by_user_id(user_id, page_params)
  end

  defp list_teams_owner_by_user_id("supporter_teams", user_id, page_params) do
    page = Teams.list_supporter_teams_ower_by_supportee_id(user_id, page_params)

    entries =
      page.entries
      |> Enum.map(fn entry ->
        %{user: entry.request_to_user, team: entry.supporter_team}
      end)

    Map.put(page, :entries, entries)
  end

  defp list_teams_owner_by_user_id("supportee_teams", user_id, page_params) do
    page = Teams.list_supportee_team_owner_by_supporter_id(user_id, page_params)

    entries =
      page.entries
      |> Enum.map(fn entry ->
        %{user: entry.request_from_user, team: entry.supportee_team}
      end)

    Map.put(page, :entries, entries)
  end
end
