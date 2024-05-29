defmodule BrightWeb.Admin.DraftSkillClassLive.SkillFormComponent do
  use BrightWeb, :live_component

  alias Bright.DraftSkillUnits

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.simple_form
        for={@form}
        id="skill-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="スキル名" />
        <:actions>
          <.button phx-disable-with="Saving...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{skill: skill} = assigns, socket) do
    changeset = DraftSkillUnits.change_draft_skill(skill)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"draft_skill" => skill_params}, socket) do
    changeset =
      socket.assigns.skill
      |> DraftSkillUnits.change_draft_skill(skill_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"draft_skill" => skill_params}, socket) do
    save_skill(socket, socket.assigns.action, skill_params)
  end

  defp save_skill(socket, :edit_skill, skill_params) do
    skill = socket.assigns.skill

    case DraftSkillUnits.update_draft_skill(skill, skill_params) do
      {:ok, _skill} ->
        {:noreply,
         socket
         |> put_flash(:info, "スキルを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_skill(socket, :new_skill, skill_params) do
    case DraftSkillUnits.create_draft_skill(skill_params) do
      {:ok, _skill} ->
        {:noreply,
         socket
         |> put_flash(:info, "スキルを作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
