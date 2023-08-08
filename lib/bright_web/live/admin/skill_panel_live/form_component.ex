defmodule BrightWeb.Admin.SkillPanelLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.SkillPanels

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage skill_panel records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="skill_panel-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          type="select"
          label="career_fields"
          field={@form[:career_field_id]}
          options={@career_fields}
        />
        <.label>Skill classes</.label>
        <.inputs_for :let={scf} field={@form[:skill_classes]}>
          <input type="hidden" name="skill_panel[skill_classes_sort][]" value={scf.index} />
          <.input field={scf[:name]} type="text" label="Name" />
          <label class="cursor-pointer">
            <input
              type="checkbox"
              name="skill_panel[skill_classes_drop][]"
              value={scf.index}
              class="hidden"
            /> delete
          </label>
        </.inputs_for>
        <label class="block cursor-pointer">
          <input type="checkbox" name="skill_panel[skill_classes_sort][]" class="hidden" />
          add skill class
        </label>
        <:actions>
          <.button phx-disable-with="Saving...">Save Skill panel</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{skill_panel: skill_panel} = assigns, socket) do
    changeset =
      skill_panel
      |> preload_assoc()
      |> SkillPanels.change_skill_panel()

    career_fields =
      Bright.Jobs.list_career_fields()
      |> Enum.map(fn %{id: id_value, name_ja: name_value} ->
        {String.to_atom(name_value), id_value}
      end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:career_fields, career_fields)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"skill_panel" => skill_panel_params}, socket) do
    changeset =
      socket.assigns.skill_panel
      |> preload_assoc()
      |> SkillPanels.change_skill_panel(skill_panel_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"skill_panel" => skill_panel_params}, socket) do
    save_skill_panel(socket, socket.assigns.action, skill_panel_params)
  end

  defp save_skill_panel(socket, :edit, skill_panel_params) do
    skill_panel = preload_assoc(socket.assigns.skill_panel)

    case SkillPanels.update_skill_panel(skill_panel, skill_panel_params) do
      {:ok, skill_panel} ->
        notify_parent({:saved, preload_assoc(skill_panel)})

        {:noreply,
         socket
         |> put_flash(:info, "Skill panel updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_skill_panel(socket, :new, skill_panel_params) do
    case SkillPanels.create_skill_panel(skill_panel_params) do
      {:ok, skill_panel} ->
        notify_parent({:saved, preload_assoc(skill_panel)})

        {:noreply,
         socket
         |> put_flash(:info, "Skill panel created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp preload_assoc(skill_panel),
    do: skill_panel |> Bright.Repo.preload([:skill_classes, :career_field])
end
