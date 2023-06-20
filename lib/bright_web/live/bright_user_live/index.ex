defmodule BrightWeb.BrightUserLive.Index do
  use BrightWeb, :live_view

  alias Bright.Users
  alias Bright.Users.BrightUser

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :bright_users, Users.list_bright_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Bright user")
    |> assign(:bright_user, Users.get_bright_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Bright user")
    |> assign(:bright_user, %BrightUser{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Bright users")
    |> assign(:bright_user, nil)
  end

  @impl true
  def handle_info({BrightWeb.BrightUserLive.FormComponent, {:saved, bright_user}}, socket) do
    {:noreply, stream_insert(socket, :bright_users, bright_user)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bright_user = Users.get_bright_user!(id)
    {:ok, _} = Users.delete_bright_user(bright_user)

    {:noreply, stream_delete(socket, :bright_users, bright_user)}
  end
end
