defmodule BrightWeb.TeamCreateLive do
  use BrightWeb, :live_view

  alias Bright.Accounts
  alias Bright.Teams

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:users, [])

    {:ok, socket}
  end

  @impl true
  def handle_event("add_user", %{"search_word" => search_word}, socket) do
    current_users = socket.assigns.users
    user = Accounts.get_user_by_name(search_word)

    # メンバーユーザー一時リストに追加
    added_users =
      [user | current_users]
      |> Enum.reverse()

    {:noreply, assign(socket, :users, added_users)}
  end

  def handle_event("remove_user", %{"id" => id}, socket) do
    current_users = socket.assigns.users

    # メンバーユーザー一時リストから削除
    removed_users =
      current_users
      |> Enum.reject(fn x -> x.id == id end)

    {:noreply, assign(socket, :users, removed_users)}
  end

  @impl true
  def handle_event("create_team", %{"team_name" => team_name}, socket) do
    member_users = socket.assigns.users
    admin_user = socket.assigns.current_user

    case Teams.create_team_multi(team_name, admin_user, member_users) do
      {:ok, _team} ->
        {:noreply,
         socket
         |> put_flash(:info, "チームを登録しました")
         |> redirect(to: ~p"/mypage")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset)}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply,
     socket
     |> redirect(to: ~p"/mypage")}
  end
end
