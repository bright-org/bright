defmodule BrightWeb.Admin.SkillPanelLive.FormComponent do
  use BrightWeb, :live_component

  alias BrightWeb.TimelineHelper
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
        <.label>Skill classes</.label>
        <.inputs_for :let={scf} field={@form[:skill_classes]}>
          <input type="hidden" name="skill_panel[skill_classes_sort][]" value={scf.index} />
          <.input field={scf[:name]} type="text" label="Name" />
          <.input field={scf[:locked_date]} type="hidden" value={scf[:locked_date].value || @locked_date} />
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
          add skill class (locked_date: <%= @locked_date %>)
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
    # 現スキルパネルを操作しているためlocked_dateを1つ前のバッチ更新日相当日付としている
    timeline = TimelineHelper.get_current()
    locked_date = TimelineHelper.get_shift_date_from_date(timeline.future_date, -1)

    changeset =
      skill_panel
      |> preload_assoc()
      |> SkillPanels.change_skill_panel()

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign(:locked_date, locked_date)}
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

  defp preload_assoc(skill_panel), do: skill_panel |> Bright.Repo.preload(:skill_classes)
end
