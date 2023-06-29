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
        <.input field={@form[:locked_date]} type="date" label="Locked date" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.label>Skill classes</.label>
        <.inputs_for :let={scf} field={@form[:skill_classes]}>
          <div class="border p-4">
            <.input field={scf[:name]} type="text" label="Name" />
            <label
              class="cursor-pointer"
              phx-click={JS.push("delete_skill_class", value: %{id: scf.data.id, index: scf.index})}
              phx-target={@myself}
            >
              delete
            </label>
          </div>
        </.inputs_for>
        <label class="cursor-pointer" phx-click="add_skill_class" phx-target={@myself}>
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

    {:ok,
     socket
     |> assign(assigns)
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

  def handle_event("add_skill_class", _value, socket) do
    changeset = socket.assigns.changeset

    skill_classes =
      changeset.changes
      |> Map.get(
        :skill_classes,
        Enum.map(changeset.data.skill_classes, &Bright.SkillPanels.SkillClass.changeset(&1, %{}))
      )
      |> Enum.concat([%Bright.SkillPanels.SkillClass{}])

    changeset = Ecto.Changeset.put_assoc(changeset, :skill_classes, skill_classes)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("delete_skill_class", %{"id" => id, "index" => index}, socket) do
    changeset = socket.assigns.changeset

    skill_classes =
      changeset.changes
      |> Map.get(
        :skill_classes,
        Enum.map(changeset.data.skill_classes, &Bright.SkillPanels.SkillClass.changeset(&1, %{}))
      )
      |> then(fn changesets ->
        if id do
          Enum.reject(changesets, &(&1.data.id === id))
        else
          List.delete_at(changesets, index)
        end
      end)

    changeset = Ecto.Changeset.put_assoc(changeset, :skill_classes, skill_classes)

    {:noreply, assign_form(socket, changeset)}
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
    socket
    |> assign(:changeset, changeset)
    |> assign(:form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp preload_assoc(skill_panel), do: skill_panel |> Bright.Repo.preload(:skill_classes)
end
