defmodule BrightWeb.Admin.SkillLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.SkillUnits

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage skill records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="skill"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:position]} type="text" label="Position" />
        <.label>Skill reference</.label>
        <.inputs_for :let={sr} field={@form[:skill_reference]}>
          <.input field={sr[:url]} type="text" label="URL" />
        </.inputs_for>
        <.label>Skill exam</.label>
        <.inputs_for :let={se} field={@form[:skill_exam]}>
          <.input field={se[:url]} type="text" label="URL" />
        </.inputs_for>
        <:actions>
          <.button phx-disable-with="Saving...">Save Skill</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{skill: skill} = assigns, socket) do
    skill = preload_assoc(skill)

    changeset =
      skill
      |> SkillUnits.change_skill()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(skill: skill)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"skill" => skill_params}, socket) do
    changeset =
      socket.assigns.skill
      |> SkillUnits.change_skill(skill_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"skill" => skill_params}, socket) do
    save_skill(socket, socket.assigns.action, skill_params)
  end

  defp save_skill(socket, :edit, skill_params) do
    case SkillUnits.update_skill(socket.assigns.skill, skill_params) do
      {:ok, skill} ->
        skill = Bright.Repo.preload(skill, [:skill_category])

        {:noreply,
         socket
         |> put_flash(:info, "Skill updated successfully")
         |> push_navigate(to: "/admin/skill_units/#{skill.skill_category.skill_unit_id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp preload_assoc(skill_category) do
    skill_category
    |> Bright.Repo.preload([:skill_reference, :skill_exam])
  end
end
