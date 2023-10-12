defmodule BrightWeb.Admin.JobLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.{Jobs, CareerFields, SkillPanels}
  alias Bright.Jobs.Job

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage job records in your database.</:subtitle>
      </.header>
      <.simple_form
        for={@form}
        id="job-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input
          type="select"
          label="rank"
          field={@form[:rank]}
          options={Ecto.Enum.mappings(Job, :rank)}
        />
        <.input field={@form[:position]} type="number" label="Position" />
        <.label>CareerFields</.label>
        <.inputs_for :let={cf} field={@form[:career_field_jobs]}>
          <input type="hidden" name="job[career_field_jobs_sort][]" value={cf.index} />
          <.input
            field={cf[:career_field_id]}
            type="select"
            label="CareerField"
            prompt="キャリアフィールドを選択してください"
            options={@career_field_options}
          />
          <label class="cursor-pointer">
            <input
              type="checkbox"
              name="job[career_field_jobs_drop][]"
              value={cf.index}
              class="hidden"
            /> delete
          </label>
        </.inputs_for>
        <label class="block cursor-pointer">
          <input type="checkbox" name="job[career_field_jobs_sort][]" class="hidden" />
          add career field
        </label>
        <.label>SkillPanels</.label>
        <.inputs_for :let={sp} field={@form[:job_skill_panels]}>
          <input type="hidden" name="job[job_skill_panels_sort][]" value={sp.index} />
          <.input
            field={sp[:skill_panel_id]}
            type="select"
            label="SkillPanel"
            prompt="スキルパネルを選択してください"
            options={@skill_panel_options}
          />
          <label class="cursor-pointer">
            <input
              type="checkbox"
              name="job[job_skill_panels_drop][]"
              value={sp.index}
              class="hidden"
            /> delete
          </label>
        </.inputs_for>
        <label class="block cursor-pointer">
          <input type="checkbox" name="job[job_skill_panels_sort][]" class="hidden" />
          add skill panel
        </label>
        <:actions>
          <.button phx-disable-with="Saving...">Save Job</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{job: job} = assigns, socket) do
    changeset =
      job
      |> preload_assoc()
      |> Jobs.change_job()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:career_field_options, career_field_options())
     |> assign(:skill_panel_options, skill_panel_options())
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"job" => job_params}, socket) do
    changeset =
      socket.assigns.job
      |> preload_assoc()
      |> Jobs.change_job(job_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"job" => job_params}, socket) do
    save_job(socket, socket.assigns.action, job_params)
  end

  defp save_job(socket, :edit, job_params) do
    job = preload_assoc(socket.assigns.job)

    case Jobs.update_job(job, job_params) do
      {:ok, job} ->
        notify_parent({:saved, preload_assoc(job)})

        {:noreply,
         socket
         |> put_flash(:info, "Job updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_job(socket, :new, job_params) do
    case Jobs.create_job(job_params) do
      {:ok, job} ->
        notify_parent({:saved, preload_assoc(job)})

        {:noreply,
         socket
         |> put_flash(:info, "Job created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp career_field_options() do
    CareerFields.list_career_fields()
    |> Enum.map(&{&1.name_ja, &1.id})
  end

  defp skill_panel_options() do
    SkillPanels.list_skill_panels()
    |> Enum.map(&{&1.name, &1.id})
  end

  defp preload_assoc(job) do
    Bright.Repo.preload(job, [
      :career_fields,
      :career_field_jobs,
      :skill_panels,
      :job_skill_panels
    ])
  end
end
