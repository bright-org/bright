defmodule BrightWeb.Admin.CareerWantLive.Index do
  use BrightWeb, :live_view

  alias Bright.Jobs
  alias Bright.Jobs.CareerWant

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :career_wants, Jobs.list_career_wants())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Career want")
    |> assign(:career_want, Jobs.get_career_want!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Career want")
    |> assign(:career_want, %CareerWant{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Career wants")
    |> assign(:career_want, nil)
  end

  @impl true
  def handle_info({BrightWeb.Admin.CareerWantLive.FormComponent, {:saved, career_want}}, socket) do
    {:noreply, stream_insert(socket, :career_wants, career_want)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    career_want = Jobs.get_career_want!(id)
    {:ok, _} = Jobs.delete_career_want(career_want)

    {:noreply, stream_delete(socket, :career_wants, career_want)}
  end
end
