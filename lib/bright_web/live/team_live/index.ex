defmodule BrightWeb.TeamLive.Index do
  use BrightWeb, :live_view

  alias Bright.Teams
  alias Bright.Teams.Team
  alias Bright.Users
  alias Bright.Users.BrightUser

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:users, [])
      |> stream(:teams, Teams.list_teams())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Team")
    |> assign(:team, Teams.get_team!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "チーム作成")
    |> assign(:users, [])
    |> assign(:team, %Team{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Teams")
    |> assign(:team, nil)
  end

  @impl true
  def handle_info({BrightWeb.TeamLive.FormComponent, {:saved, team}}, socket) do
    {:noreply, stream_insert(socket, :teams, team)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    team = Teams.get_team!(id)
    {:ok, _} = Teams.delete_team(team)

    {:noreply, stream_delete(socket, :teams, team)}
  end

  @impl true
  def handle_event("add_user", %{"handle_name" => handle_name}, socket) do
    current_users = socket.assigns.users
    user = Users.get_bright_user_by_handle_name(handle_name)

    added_users =
      [user | current_users]
      |> Enum.reverse()

    socket =
      socket
      |> assign(:users, added_users)

    {:noreply, assign(socket, :users, added_users)}
  end

  def handle_event("remove_user", %{"id" => id}, socket) do
    current_users = socket.assigns.users

    # メンバー一時リストから削除
    removed_users =
      current_users
      |> Enum.reject(fn x -> x.id == id end)

    socket =
      socket
      |> assign(:users, removed_users)

    {:noreply, socket}
  end
end
