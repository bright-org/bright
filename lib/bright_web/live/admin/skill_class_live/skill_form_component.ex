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
        <.input field={@form[:name]} type="text" label="スキル名" />
        <.input field={@form[:skill_category_id]} type="hidden" />
        <:actions>
          <.button phx-disable-with="Saving...">保存</.button>
          <.button
            :if={@action == :edit_skill && not @single_row_data?}
            class="!bg-red-600 hover:!bg-red-500"
            type="button"
            data-confirm="この操作は取り消せません。同じ名前で再作成しても削除したスキルとは違うものになります。削除しますか？"
            phx-click="delete"
            phx-target={@myself}
          >削除</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{skill: skill} = assigns, socket) do
    changeset = SkillUnits.change_skill(skill)

    {:ok,
     socket
     |> assign(assigns)
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

  def handle_event("delete", _params, socket) do
    skill = socket.assigns.skill
    SkillUnits.delete_skill(skill)

    {:noreply,
     socket
     |> put_flash(:info, "スキルを削除しました")
     |> push_patch(to: socket.assigns.patch)}
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

  defp save_skill(socket, :new_skill, skill_params) do
    case SkillUnits.create_skill(skill_params) do
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
