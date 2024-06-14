defmodule BrightWeb.Admin.DraftSkillClassLive.SkillCategoryReplaceFormComponent do
  use BrightWeb, :live_component

  alias Bright.DraftSkillUnits
  alias BrightWeb.Admin.DraftSkillClassLive.SkillSelectionComponent

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header class="my-2">
        <p><%= @skill_category.name %></p>
        <:subtitle>他の知識エリアへの移動</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="skill-category-replace-form"
        phx-target={@myself}
        phx-submit="save"
      >
        <.input field={@form[:draft_skill_unit_id]} value={@skill_unit && @skill_unit.id} type="hidden" />

        <.live_component
          id="skill-unit-selection"
          module={SkillSelectionComponent}
          skill_panel={@this_skill_panel}
          target={Bright.DraftSkillUnits.DraftSkillUnit}
          on_select={on_select_skill_unit(@id)}
        />

        <:actions>
          <.button phx-disable-with="Saving...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{form_skill_unit: skill_unit}, socket) do
    # ParentSelectionComponentの選択結果受け取り
    {:ok, assign(socket, :skill_unit, skill_unit)}
  end

  def update(%{skill_category: skill_category} = assigns, socket) do
    changeset = DraftSkillUnits.change_draft_skill_category(skill_category)
    skill_unit = DraftSkillUnits.get_draft_skill_unit!(skill_category.draft_skill_unit_id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:skill_unit, skill_unit)
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"draft_skill_category" => params}, socket) do
    skill_category = socket.assigns.skill_category

    skill_unit =
      DraftSkillUnits.get_draft_skill_unit!(params["draft_skill_unit_id"])

    # 末尾追加とする
    position =
      DraftSkillUnits.get_max_position(skill_unit, :draft_skill_categories)
      |> Kernel.+(1)

    params = Map.put(params, "position", position)

    case DraftSkillUnits.update_draft_skill_category(skill_category, params) do
      {:ok, _skill_category} ->
        {:noreply,
         socket
         |> put_flash(:info, "カテゴリーを移動しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp on_select_skill_unit(id) do
    fn skill_unit ->
      send_update(__MODULE__, id: id, form_skill_unit: skill_unit)
    end
  end
end
