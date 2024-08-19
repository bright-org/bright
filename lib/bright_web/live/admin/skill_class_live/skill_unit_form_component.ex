defmodule BrightWeb.Admin.SkillClassLive.SkillUnitFormComponent do
  use BrightWeb, :live_component

  alias Bright.SkillUnits
  alias BrightWeb.TimelineHelper

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
              :if={@action == :edit_skill_unit}
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
    changeset = SkillUnits.change_skill_unit(skill_unit)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"skill_unit" => params}, socket) do
    changeset =
      socket.assigns.skill_unit
      |> SkillUnits.change_skill_unit(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"skill_unit" => params}, socket) do
    save_skill_unit(socket, socket.assigns.action, params)
  end

  def handle_event("remove", _params, socket) do
    %{
      skill_class: skill_class,
      skill_unit: skill_unit
    } = socket.assigns

    SkillUnits.delete_skill_class_unit(skill_class, skill_unit)

    {:noreply,
     socket
     |> put_flash(:info, "知識エリアの紐づけを解除しました")
     |> push_patch(to: socket.assigns.patch)}
  end

  def handle_event("delete", _params, socket) do
    skill_unit = socket.assigns.skill_unit
    SkillUnits.delete_skill_unit(skill_unit)

    {:noreply,
     socket
     |> put_flash(:info, "知識エリアを削除しました")
     |> push_patch(to: socket.assigns.patch)}
  end

  defp save_skill_unit(socket, :edit_skill_unit, params) do
    skill_unit = socket.assigns.skill_unit

    case SkillUnits.update_skill_unit(skill_unit, params) do
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
    params = Map.put(params, "locked_date", get_locked_date())

    case SkillUnits.create_skill_unit(skill_class, params) do
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

  defp get_locked_date do
    # locked_dateを1つ前のバッチ更新日相当日付としている
    timeline = TimelineHelper.get_current()
    TimelineHelper.get_shift_date_from_date(timeline.future_date, -1)
  end
end
