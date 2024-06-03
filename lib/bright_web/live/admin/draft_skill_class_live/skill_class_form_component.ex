defmodule BrightWeb.Admin.DraftSkillClassLive.SkillClassFormComponent do
  use BrightWeb, :live_component

  alias Bright.DraftSkillPanels

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.simple_form
        for={@form}
        id="skill-class-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="スキルクラス名" />
        <:actions>
          <.button phx-disable-with="Saving...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{skill_class: skill_class} = assigns, socket) do
    changeset = DraftSkillPanels.change_draft_skill_class(skill_class)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"draft_skill_class" => params}, socket) do
    changeset =
      socket.assigns.skill_class
      |> DraftSkillPanels.change_draft_skill_class(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"draft_skill_class" => params}, socket) do
    save_skill_class(socket, socket.assigns.action, params)
  end

  defp save_skill_class(socket, :edit_skill_class, params) do
    skill_class = socket.assigns.skill_class

    case DraftSkillPanels.update_draft_skill_class(skill_class, params) do
      {:ok, _skill} ->
        {:noreply,
         socket
         |> put_flash(:info, "スキルクラスを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
