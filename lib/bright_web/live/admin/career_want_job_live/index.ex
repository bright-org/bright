defmodule BrightWeb.Admin.CareerWantJobLive.Index do
  use BrightWeb, :live_view

  alias Bright.Jobs
  alias Bright.CareerWants
  alias Bright.Jobs.CareerWantJob

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :career_want_jobs, Jobs.list_career_want_jobs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Career want job")
    |> assign(:career_want_job, Jobs.get_career_want_job!(id))
  end

  defp apply_action(socket, :new, _params) do
    career_wants_options = CareerWants.list_career_wants() |> map_to_select_option()
    jobs_options = Jobs.list_jobs() |> map_to_select_option()

    socket
    |> assign(:page_title, "New Career want job")
    |> assign(:career_want_job, %CareerWantJob{})
    |> assign(:career_wants, career_wants_options)
    |> assign(:jobs, jobs_options)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Career want jobs")
    |> assign(:career_want_job, nil)
  end

  @impl true
  def handle_info(
        {BrightWeb.Admin.CareerWantJobLive.FormComponent, {:saved, career_want_job}},
        socket
      ) do
    {:noreply, stream_insert(socket, :career_want_jobs, career_want_job)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    career_want_job = Jobs.get_career_want_job!(id)
    {:ok, _} = Jobs.delete_career_want_job(career_want_job)

    {:noreply, stream_delete(socket, :career_want_jobs, career_want_job)}
  end

  defp map_to_select_option(param_map) do
    param_map
    |> Enum.map(fn %{id: id_value, name: name_value} ->
      {String.to_atom(name_value), id_value}
    end)
  end
end
