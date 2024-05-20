defmodule BrightWeb.Admin.CareerWantLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.{CareerWants, Jobs}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage career_want records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="career_want-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:position]} type="number" label="Position" />
        <.label>Jobs</.label>
        <.inputs_for :let={j} field={@form[:career_want_jobs]}>
          <input type="hidden" name="career_want[career_want_jobs_sort][]" value={j.index} />
          <.input
            field={j[:job_id]}
            type="select"
            label="Job"
            prompt="ジョブを選択してください"
            options={@job_options}
          />
          <label class="cursor-pointer">
            <input
              type="checkbox"
              name="career_want[career_want_jobs_drop][]"
              value={j.index}
              class="hidden"
            /> delete
          </label>
        </.inputs_for>
        <label class="block cursor-pointer">
          <input type="checkbox" name="career_want[career_want_jobs_sort][]" class="hidden" /> add job
        </label>

        <:actions>
          <.button phx-disable-with="Saving...">Save Career want</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{career_want: career_want} = assigns, socket) do
    changeset =
      career_want
      |> preload_assoc()
      |> CareerWants.change_career_want()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:job_options, job_options())
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"career_want" => career_want_params}, socket) do
    changeset =
      socket.assigns.career_want
      |> preload_assoc()
      |> CareerWants.change_career_want(career_want_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"career_want" => career_want_params}, socket) do
    save_career_want(socket, socket.assigns.action, career_want_params)
  end

  defp save_career_want(socket, :edit, career_want_params) do
    career_want = preload_assoc(socket.assigns.career_want)

    case CareerWants.update_career_want(career_want, career_want_params) do
      {:ok, career_want} ->
        notify_parent({:saved, preload_assoc(career_want)})

        {:noreply,
         socket
         |> put_flash(:info, "Career want updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_career_want(socket, :new, career_want_params) do
    case CareerWants.create_career_want(career_want_params) do
      {:ok, career_want} ->
        notify_parent({:saved, preload_assoc(career_want)})

        {:noreply,
         socket
         |> put_flash(:info, "Career want created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp job_options() do
    Jobs.list_jobs()
    |> Enum.map(&{&1.name, &1.id})
  end

  defp preload_assoc(career_want) do
    Bright.Repo.preload(career_want, [:jobs, :career_want_jobs])
  end
end
