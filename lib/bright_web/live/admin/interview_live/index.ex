defmodule BrightWeb.InterviewLive.Index do
  use BrightWeb, :live_view

  alias Bright.Recruits
  alias Bright.Recruits.Interview

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :recruit_inteview, Recruits.list_recruit_inteview())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Interview")
    |> assign(:interview, Recruits.get_interview!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Interview")
    |> assign(:interview, %Interview{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Recruit inteview")
    |> assign(:interview, nil)
  end

  @impl true
  def handle_info({BrightWeb.InterviewLive.FormComponent, {:saved, interview}}, socket) do
    {:noreply, stream_insert(socket, :recruit_inteview, interview)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    interview = Recruits.get_interview!(id)
    {:ok, _} = Recruits.delete_interview(interview)

    {:noreply, stream_delete(socket, :recruit_inteview, interview)}
  end
end
