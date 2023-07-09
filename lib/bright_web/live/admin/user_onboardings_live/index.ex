defmodule BrightWeb.Admin.UserOnboardingsLive.Index do
  use BrightWeb, :live_view

  alias Bright.Onboardings
  alias Bright.Onboardings.UserOnboardings

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :user_onboardings_collection, Onboardings.list_user_onboardings())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User onboardings")
    |> assign(:user_onboardings, Onboardings.get_user_onboardings!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User onboardings")
    |> assign(:user_onboardings, %UserOnboardings{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing User onboardings")
    |> assign(:user_onboardings, nil)
  end

  @impl true
  def handle_info({BrightWeb.Admin.UserOnboardingsLive.FormComponent, {:saved, user_onboardings}}, socket) do
    {:noreply, stream_insert(socket, :user_onboardings_collection, user_onboardings)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_onboardings = Onboardings.get_user_onboardings!(id)
    {:ok, _} = Onboardings.delete_user_onboardings(user_onboardings)

    {:noreply, stream_delete(socket, :user_onboardings_collection, user_onboardings)}
  end
end
