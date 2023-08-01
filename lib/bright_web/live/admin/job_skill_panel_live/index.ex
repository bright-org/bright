defmodule BrightWeb.Admin.JobSkillPanelLive.Index do
  use BrightWeb, :live_view

  alias Bright.Jobs
  alias Bright.Jobs.JobSkillPanel
  alias Bright.SkillPanels

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(socket, :job_skill_panels, Jobs.list_job_skill_panels_with_jobs_and_skill_panels())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    job_options = Jobs.list_jobs() |> map_to_select_option()
    skill_panel_options = SkillPanels.list_skill_panels() |> map_to_select_option()

    socket
    |> assign(:page_title, "Edit Job skill panel")
    |> assign(:job_skill_panel, Jobs.get_job_skill_panel!(id))
    |> assign(:job_options, job_options)
    |> assign(:skill_panel_options, skill_panel_options)
  end

  defp apply_action(socket, :new, _params) do
    job_options = Jobs.list_jobs() |> map_to_select_option()
    skill_panel_options = SkillPanels.list_skill_panels() |> map_to_select_option()

    socket
    |> assign(:page_title, "New Job skill panel")
    |> assign(:job_skill_panel, %JobSkillPanel{})
    |> assign(:job_options, job_options)
    |> assign(:skill_panel_options, skill_panel_options)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Job skill panels")
    |> assign(:job_skill_panel, nil)
  end

  @impl true
  def handle_info(
        {BrightWeb.Admin.JobSkillPanelLive.FormComponent, {:saved, job_skill_panel}},
        socket
      ) do
    {:noreply, stream_insert(socket, :job_skill_panels, job_skill_panel)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    job_skill_panel = Jobs.get_job_skill_panel!(id)
    {:ok, _} = Jobs.delete_job_skill_panel(job_skill_panel)

    {:noreply, stream_delete(socket, :job_skill_panels, job_skill_panel)}
  end

  defp map_to_select_option(param_map) do
    param_map
    |> Enum.map(fn %{id: id_value, name: name_value} ->
      {String.to_atom(name_value), id_value}
    end)
  end
end
