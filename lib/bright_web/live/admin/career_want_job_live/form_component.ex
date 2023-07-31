defmodule BrightWeb.Admin.CareerWantJobLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Jobs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage career_want_job records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="career_want_job-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          type="select"
          label="career_wants"
          field={@form[:career_want_id]}
          options={@career_wants}
        />
        <.input
          type="select"
          label="jobs"
          field={@form[:job_id]}
          options={@jobs}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Career want job</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{career_want_job: career_want_job} = assigns, socket) do
    changeset = Jobs.change_career_want_job(career_want_job)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"career_want_job" => career_want_job_params}, socket) do
    changeset =
      socket.assigns.career_want_job
      |> Jobs.change_career_want_job(career_want_job_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"career_want_job" => career_want_job_params}, socket) do
    save_career_want_job(socket, socket.assigns.action, career_want_job_params)
  end

  defp save_career_want_job(socket, :edit, career_want_job_params) do
    case Jobs.update_career_want_job(socket.assigns.career_want_job, career_want_job_params) do
      {:ok, career_want_job} ->
        notify_parent({:saved, career_want_job})

        {:noreply,
         socket
         |> put_flash(:info, "Career want job updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_career_want_job(socket, :new, career_want_job_params) do
    case Jobs.create_career_want_job(career_want_job_params) do
      {:ok, career_want_job} ->
        notify_parent({:saved, career_want_job})

        {:noreply,
         socket
         |> put_flash(:info, "Career want job created successfully")
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
