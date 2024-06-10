defmodule BrightWeb.Admin.DraftSkillClassLive.SkillCategoryFormComponent do
  use BrightWeb, :live_component

  alias Bright.DraftSkillUnits

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header class="my-2">
        <p><%= @skill_category.name %></p>
      </.header>

      <.simple_form
        for={@form}
        id="skill-category-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="カテゴリー名" />
        <.input field={@form[:draft_skill_unit_id]} type="hidden" />
        <:actions>
          <.button phx-disable-with="Saving...">保存</.button>
          <.button
            :if={@action == :edit_skill_category}
            class="!bg-red-600 hover:!bg-red-500"
            type="button"
            data-confirm="この操作は取り消せません。同じ名前で再作成しても削除したカテゴリーとは違うものになります。削除しますか？"
            phx-click="delete"
            phx-target={@myself}
          >削除</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{skill_category: skill_category} = assigns, socket) do
    changeset = DraftSkillUnits.change_draft_skill_category(skill_category)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"draft_skill_category" => params}, socket) do
    changeset =
      socket.assigns.skill_category
      |> DraftSkillUnits.change_draft_skill_category(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"draft_skill_category" => params}, socket) do
    save_skill_category(socket, socket.assigns.action, params)
  end

  def handle_event("delete", _params, socket) do
    skill_category = socket.assigns.skill_category
    DraftSkillUnits.delete_draft_skill_category(skill_category)

    {:noreply,
      socket
      |> put_flash(:info, "カテゴリーを削除しました")
      |> push_patch(to: socket.assigns.patch)}
  end

  defp save_skill_category(socket, :edit_skill_category, params) do
    skill_category = socket.assigns.skill_category

    case DraftSkillUnits.update_draft_skill_category(skill_category, params) do
      {:ok, _skill} ->
        {:noreply,
         socket
         |> put_flash(:info, "カテゴリーを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_skill_category(socket, :new_skill_category, params) do
    case DraftSkillUnits.create_draft_skill_category(params) do
      {:ok, _skill_category} ->
        {:noreply,
         socket
         |> put_flash(:info, "カテゴリーを作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
