defmodule BrightWeb.Admin.DraftSkillClassLive.SkillUnitReplaceFormComponent do
  use BrightWeb, :live_component

  alias Bright.DraftSkillPanels
  alias Bright.DraftSkillUnits
  alias BrightWeb.Admin.DraftSkillClassLive.SkillSelectionComponent

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header class="my-2">
        <p><%= @skill_unit.name %></p>
        <:subtitle>他のスキルクラスへの移動</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="skill-unit-replace-form"
        phx-target={@myself}
        phx-submit="save"
      >
        <.input field={@form[:draft_skill_class_id]} value={@skill_class && @skill_class.id} type="hidden" />

        <.live_component
          id="skill-unit-selection"
          module={SkillSelectionComponent}
          skill_panel={@this_skill_panel}
          target={Bright.DraftSkillPanels.DraftSkillClass}
          on_select={on_select_skill_class(@id)}
        />

        <:actions>
          <.button phx-disable-with="Saving...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{form_skill_class: skill_class}, socket) do
    # ParentSelectionComponentの選択結果受け取り
    {:ok, assign(socket, :skill_class, skill_class)}
  end

  def update(%{skill_unit: skill_unit, skill_class: skill_class} = assigns, socket) do
    skill_class_unit =
      DraftSkillUnits.get_draft_skill_class_unit_by(
        draft_skill_unit_id: skill_unit.id,
        draft_skill_class_id: skill_class.id
      )

    changeset = DraftSkillUnits.change_draft_skill_class_unit(skill_class_unit)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:skill_class_unit, skill_class_unit)
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"draft_skill_class_unit" => params}, socket) do
    skill_class_unit = socket.assigns.skill_class_unit
    skill_class = DraftSkillPanels.get_draft_skill_class!(params["draft_skill_class_id"])

    # 末尾追加とする
    position =
      DraftSkillUnits.get_max_position(skill_class, :draft_skill_class_units)
      |> Kernel.+(1)

    params = Map.put(params, "position", position)

    case DraftSkillUnits.update_draft_skill_class_unit(skill_class_unit, params) do
      {:ok, _skill_class_unit} ->
        {:noreply,
         socket
         |> put_flash(:info, "クラスを移動しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp on_select_skill_class(id) do
    fn skill_class ->
      send_update(__MODULE__, id: id, form_skill_class: skill_class)
    end
  end
end
