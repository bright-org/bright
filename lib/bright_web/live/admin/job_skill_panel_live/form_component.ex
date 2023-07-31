defmodule BrightWeb.Admin.JobSkillPanelLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Jobs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage job_skill_panel records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="job_skill_panel-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >

        <:actions>
          <.button phx-disable-with="Saving...">Save Job skill panel</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{job_skill_panel: job_skill_panel} = assigns, socket) do
    changeset = Jobs.change_job_skill_panel(job_skill_panel)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"job_skill_panel" => job_skill_panel_params}, socket) do
    changeset =
      socket.assigns.job_skill_panel
      |> Jobs.change_job_skill_panel(job_skill_panel_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"job_skill_panel" => job_skill_panel_params}, socket) do
    save_job_skill_panel(socket, socket.assigns.action, job_skill_panel_params)
  end

  defp save_job_skill_panel(socket, :edit, job_skill_panel_params) do
    case Jobs.update_job_skill_panel(socket.assigns.job_skill_panel, job_skill_panel_params) do
      {:ok, job_skill_panel} ->
        notify_parent({:saved, job_skill_panel})

        {:noreply,
         socket
         |> put_flash(:info, "Job skill panel updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_job_skill_panel(socket, :new, job_skill_panel_params) do
    case Jobs.create_job_skill_panel(job_skill_panel_params) do
      {:ok, job_skill_panel} ->
        notify_parent({:saved, job_skill_panel})

        {:noreply,
         socket
         |> put_flash(:info, "Job skill panel created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
