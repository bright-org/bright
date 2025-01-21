defmodule BrightWeb.Admin.CareerGroupLive.Index do
  use BrightWeb, :live_view

  alias Bright.Repo
  alias Bright.CareerGroups
  alias Bright.CareerGroups.CareerGroup

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(
       socket,
       :career_groups,
       Repo.preload(CareerGroups.list_career_groups(), :career_fields)
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Career group")
    |> assign(:career_group, CareerGroups.get_career_group!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Career group")
    |> assign(:career_group, %CareerGroup{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Career groups")
    |> assign(:career_group, nil)
  end

  @impl true
  def handle_info({BrightWeb.Admin.CareerGroupLive.FormComponent, {:saved, career_group}}, socket) do
    {:noreply, stream_insert(socket, :career_groups, career_group)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    career_group = CareerGroups.get_career_group!(id)
    {:ok, _} = CareerGroups.delete_career_group(career_group)

    {:noreply, stream_delete(socket, :career_groups, career_group)}
  end
end
