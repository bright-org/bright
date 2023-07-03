defmodule BrightWeb.Admin.SkillCategoryLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.SkillUnits

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage skill_category records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="skill_category-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.label>Skills</.label>
        <.inputs_for :let={sf} field={@form[:skills]}>
          <input type="hidden" name="skill_category[skills_sort][]" value={sf.index} />
          <.input field={sf[:name]} type="text" label="Name" />
          <.input field={sf[:position]} type="number" label="Position" />
          <label class="cursor-pointer">
            <input
              type="checkbox"
              name="skill_category[skills_drop][]"
              value={sf.index}
              class="hidden"
            /> delete
          </label>
        </.inputs_for>
        <label class="block cursor-pointer">
          <input type="checkbox" name="skill_category[skills_sort][]" class="hidden" /> add skill
        </label>
        <:actions>
          <.button phx-disable-with="Saving...">Save Skill category</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{skill_category: skill_category} = assigns, socket) do
    changeset =
      skill_category
      |> preload_assoc()
      |> SkillUnits.change_skill_category()

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"skill_category" => skill_category_params}, socket) do
    changeset =
      socket.assigns.skill_category
      |> preload_assoc()
      |> SkillUnits.change_skill_category(skill_category_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"skill_category" => skill_category_params}, socket) do
    save_skill_category(socket, socket.assigns.action, skill_category_params)
  end

  defp save_skill_category(socket, :edit, skill_category_params) do
    skill_category = preload_assoc(socket.assigns.skill_category)

    case SkillUnits.update_skill_category(skill_category, skill_category_params) do
      {:ok, skill_category} ->
        notify_parent({:saved, preload_assoc(skill_category)})

        {:noreply,
         socket
         |> put_flash(:info, "Skill category updated successfully")
         |> push_navigate(to: "/admin/skill_units/#{skill_category.skill_unit_id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp preload_assoc(skill_category) do
    skill_category
    |> Bright.Repo.preload(:skills)
  end
end
