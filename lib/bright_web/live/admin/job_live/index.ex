defmodule BrightWeb.Admin.JobLive.Index do
  use BrightWeb, :live_view

  alias Bright.{Jobs, CareerFields}
  alias Bright.Jobs.Job

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :jobs, Jobs.list_jobs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Job")
    |> assign(:job, Jobs.get_job_with_career_fileds!(id))
    |> assign(:career_fields, career_field_options())
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Job")
    |> assign(:job, %Job{})
    |> assign(:career_fields, career_field_options())
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Jobs")
    |> assign(:job, nil)
  end

  @impl true
  def handle_info({BrightWeb.Admin.JobLive.FormComponent, {:saved, job}}, socket) do
    {:noreply, stream_insert(socket, :jobs, job)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    job = Jobs.get_job!(id)
    {:ok, _} = Jobs.delete_job(job)

    {:noreply, stream_delete(socket, :jobs, job)}
  end

  defp career_field_options() do
    CareerFields.list_career_fields()
    |> Enum.map(fn %{id: id_value, name_ja: name_value} ->
      {String.to_atom(name_value), id_value}
    end)
  end
end
