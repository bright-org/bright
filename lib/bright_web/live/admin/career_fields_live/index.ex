defmodule BrightWeb.Admin.CareerFieldsLive.Index do
  use BrightWeb, :live_view

  alias Bright.Jobs
  alias Bright.Jobs.CareerFields

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :career_fields_collection, Jobs.list_career_fields())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Career fields")
    |> assign(:career_fields, Jobs.get_career_fields!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Career fields")
    |> assign(:career_fields, %CareerFields{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Career fields")
    |> assign(:career_fields, nil)
  end

  @impl true
  def handle_info({BrightWeb.Admin.CareerFieldsLive.FormComponent, {:saved, career_fields}}, socket) do
    {:noreply, stream_insert(socket, :career_fields_collection, career_fields)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    career_fields = Jobs.get_career_fields!(id)
    {:ok, _} = Jobs.delete_career_fields(career_fields)

    {:noreply, stream_delete(socket, :career_fields_collection, career_fields)}
  end
end
