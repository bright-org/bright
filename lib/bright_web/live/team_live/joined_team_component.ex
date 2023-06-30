defmodule BrightWeb.Team.JoinedTeamComponent do
  @moduledoc """
  所属チーム一覧コンポーネント
  """
  use BrightWeb, :live_component

  alias Bright.Teams

  @impl true
  def mount(socket) do
    {:ok, assign(socket, _joined_teams = [])}
  end

  @impl true
  def update(assigns, socket) do
    joined_teams = Teams.list_joined_teams_by_user_id(assigns.user_id)

    assigns =
      assigns
      |> Map.put(:joined_teams, joined_teams)

    {:ok,
     socket
     |> assign(assigns)}
  end

end
