defmodule BrightWeb.Admin.CareerFieldLive.Index do
  use BrightWeb, :live_view

  alias Bright.CareerFields
  alias Bright.CareerFields.CareerField

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :career_fields, CareerFields.list_career_fields())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Career field")
    |> assign(:career_field, CareerFields.get_career_field!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Career field")
    |> assign(:career_field, %CareerField{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Career fields")
    |> assign(:career_field, nil)
  end

  @impl true
  def handle_info({BrightWeb.Admin.CareerFieldLive.FormComponent, {:saved, career_field}}, socket) do
    {:noreply, stream_insert(socket, :career_fields, career_field)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    career_field = CareerFields.get_career_field!(id)
    {:ok, _} = CareerFields.delete_career_field(career_field)

    {:noreply, stream_delete(socket, :career_fields, career_field)}
  end
end
