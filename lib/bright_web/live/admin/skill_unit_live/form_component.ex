defmodule BrightWeb.Admin.SkillUnitLive.FormComponent do
  use BrightWeb, :live_component

  alias BrightWeb.TimelineHelper
  alias Bright.SkillUnits

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage skill_unit records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="skill_unit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <label class="block text-sm font-semibold leading-6 text-zinc-800 !mt-2">LockedDate</label>
        <p class="!mt-2 ml-2"><%= @form[:locked_date].value || @locked_date %></p>
        <.input field={@form[:locked_date]} type="hidden" value={@form[:locked_date].value || @locked_date} />

        <.label>Skill categories</.label>
        <.inputs_for :let={scf} field={@form[:skill_categories]}>
          <input type="hidden" name="skill_unit[skill_categories_sort][]" value={scf.index} />
          <.input field={scf[:name]} type="text" label="Name" />
          <.input field={scf[:position]} type="number" label="Position" />
          <label class="cursor-pointer">
            <input
              type="checkbox"
              name="skill_unit[skill_categories_drop][]"
              value={scf.index}
              class="hidden"
            /> delete
          </label>
        </.inputs_for>
        <label class="block cursor-pointer">
          <input type="checkbox" name="skill_unit[skill_categories_sort][]" class="hidden" />
          add skill category
        </label>
        <.label>Skill classes</.label>
        <.inputs_for :let={scf} field={@form[:skill_class_units]}>
          <input type="hidden" name="skill_unit[skill_class_units_sort][]" value={scf.index} />
          <.input
            field={scf[:skill_class_id]}
            type="select"
            label="Skill class"
            options={@skill_class_options}
          />
          <.input field={scf[:position]} type="number" label="Position" />
          <label class="cursor-pointer">
            <input
              type="checkbox"
              name="skill_unit[skill_class_units_drop][]"
              value={scf.index}
              class="hidden"
            /> delete
          </label>
        </.inputs_for>
        <label class="block cursor-pointer">
          <input type="checkbox" name="skill_unit[skill_class_units_sort][]" class="hidden" />
          add skill category
        </label>
        <:actions>
          <.button phx-disable-with="Saving...">Save Skill unit</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{skill_unit: skill_unit} = assigns, socket) do
    # 現スキルパネルを操作しているためlocked_dateを1つ前のバッチ更新日相当日付としている
    timeline = TimelineHelper.get_current()
    locked_date = TimelineHelper.get_shift_date_from_date(timeline.future_date, -1)

    skill_class_options =
      Bright.SkillPanels.list_skill_classes()
      |> Bright.Repo.preload(:skill_panel)
      |> Enum.map(fn skill_class ->
        {"#{skill_class.skill_panel.name} > #{skill_class.name}", skill_class.id}
      end)

    changeset =
      skill_unit
      |> preload_assoc()
      |> SkillUnits.change_skill_unit()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:skill_class_options, skill_class_options)
     |> assign_form(changeset)
     |> assign(:locked_date, locked_date)}
  end

  @impl true
  def handle_event("validate", %{"skill_unit" => skill_unit_params}, socket) do
    changeset =
      socket.assigns.skill_unit
      |> preload_assoc()
      |> SkillUnits.change_skill_unit(skill_unit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"skill_unit" => skill_unit_params}, socket) do
    save_skill_unit(socket, socket.assigns.action, skill_unit_params)
  end

  defp save_skill_unit(socket, :edit, skill_unit_params) do
    skill_unit = preload_assoc(socket.assigns.skill_unit)

    case SkillUnits.update_skill_unit(skill_unit, skill_unit_params) do
      {:ok, skill_unit} ->
        notify_parent({:saved, preload_assoc(skill_unit)})

        {:noreply,
         socket
         |> put_flash(:info, "Skill unit updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_skill_unit(socket, :new, skill_unit_params) do
    case SkillUnits.create_skill_unit(skill_unit_params) do
      {:ok, skill_unit} ->
        notify_parent({:saved, preload_assoc(skill_unit)})

        {:noreply,
         socket
         |> put_flash(:info, "Skill unit created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp preload_assoc(skill_unit) do
    skill_unit
    |> Bright.Repo.preload([:skill_categories, :skill_class_units])
  end
end
