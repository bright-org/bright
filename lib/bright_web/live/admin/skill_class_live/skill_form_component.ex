defmodule BrightWeb.Admin.SkillClassLive.SkillFormComponent do
  use BrightWeb, :live_component

  alias Bright.SkillUnits

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header class="my-2">
        <p><%= @skill.name %></p>
      </.header>

      <.simple_form
        for={@form}
        id="skill-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.label>教材リンク</.label>
        <.inputs_for :let={sr} field={@form[:skill_reference]}>
          <.input field={sr[:url]} type="text" label="URL" />
        </.inputs_for>
        <.label>試験リンク</.label>
        <.inputs_for :let={se} field={@form[:skill_exam]}>
          <.input field={se[:url]} type="text" label="URL" />
        </.inputs_for>

        <:actions>
          <.button phx-disable-with="Saving...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{skill: skill} = assigns, socket) do
    skill = preload_assoc(skill)
    changeset = SkillUnits.change_skill(skill)

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

  defp save_skill(socket, :edit_skill, skill_params) do
    skill = socket.assigns.skill

    case SkillUnits.update_skill(skill, skill_params) do
      {:ok, _skill} ->
        {:noreply,
         socket
         |> put_flash(:info, "スキルを更新しました")
         |> push_patch(to: socket.assigns.patch)}

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
