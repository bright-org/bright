defmodule BrightWeb.Admin.DraftSkillClassLive.SkillUnitFormComponent do
  use BrightWeb, :live_component

  alias Bright.DraftSkillUnits

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header class="my-2">
        <p><%= @skill_unit.name %></p>
      </.header>

      <.simple_form
        for={@form}
        id="skill-unit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="知識エリア名" />
        <:actions>
          <.button phx-disable-with="Saving...">保存</.button>

          <div class="flex gap-x-2">
            <.button
              :if={@action == :edit_skill_unit && @removable?}
              class="!bg-orange-400 hover:!bg-orange-300"
              type="button"
              data-confirm="このスキルクラスとの紐づけを解除しますか？"
              phx-click="remove"
              phx-target={@myself}
            >紐づけ解除</.button>

            <.button
              :if={@action == :edit_skill_unit}
              class="!bg-red-600 hover:!bg-red-500"
              type="button"
              data-confirm="この操作は取り消せません。同じ名前で再作成しても削除した知識エリアとは違うものになります。削除しますか？"
              phx-click="delete"
              phx-target={@myself}
            >削除</.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{skill_unit: skill_unit} = assigns, socket) do
    changeset = DraftSkillUnits.change_draft_skill_unit(skill_unit)
    removable? = get_removable_skill_unit?(skill_unit)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:removable?, removable?)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"draft_skill_unit" => params}, socket) do
    changeset =
      socket.assigns.skill_unit
      |> DraftSkillUnits.change_draft_skill_unit(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"draft_skill_unit" => params}, socket) do
    save_skill_unit(socket, socket.assigns.action, params)
  end

  def handle_event("remove", _params, socket) do
    %{
      skill_class: skill_class,
      skill_unit: skill_unit
    } = socket.assigns

    DraftSkillUnits.delete_draft_skill_class_unit(skill_class, skill_unit)

    {:noreply,
     socket
     |> put_flash(:info, "知識エリアの紐づけを解除しました")
     |> push_patch(to: socket.assigns.patch)}
  end

  def handle_event("delete", _params, socket) do
    skill_unit = socket.assigns.skill_unit
    DraftSkillUnits.delete_draft_skill_unit(skill_unit)

    {:noreply,
     socket
     |> put_flash(:info, "知識エリアを削除しました")
     |> push_patch(to: socket.assigns.patch)}
  end

  defp save_skill_unit(socket, :edit_skill_unit, params) do
    skill_unit = socket.assigns.skill_unit

    case DraftSkillUnits.update_draft_skill_unit(skill_unit, params) do
      {:ok, _skill} ->
        {:noreply,
         socket
         |> put_flash(:info, "知識エリアを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_skill_unit(socket, :new_skill_unit, params) do
    %{skill_class: skill_class} = socket.assigns

    case DraftSkillUnits.create_draft_skill_unit(skill_class, params) do
      {:ok, _skill_unit} ->
        {:noreply,
         socket
         |> put_flash(:info, "知識エリアを作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp get_removable_skill_unit?(skill_unit) do
    # スキルクラスに１つしか紐づいていないなら紐づき解除不可とする
    # UI上でデータが行方不明になるため
    Ecto.assoc(skill_unit, :draft_skill_class_units)
    |> Bright.Repo.aggregate(:count)
    |> then(&(&1 > 1))
  end
end
