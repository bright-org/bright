defmodule BrightWeb.Admin.DraftSkillClassLive.SkillReplaceFormComponent do
  use BrightWeb, :live_component

  alias Bright.DraftSkillUnits
  alias BrightWeb.Admin.DraftSkillClassLive.SkillSelectionComponent

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header class="my-2">
        <p><%= @skill.name %></p>
        <:subtitle>他のカテゴリーへの移動</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="skill-replace-form"
        phx-target={@myself}
        phx-submit="save"
      >
        <.input field={@form[:draft_skill_category_id]} value={@skill_category && @skill_category.id} type="hidden" />

        <.live_component
          id="skill-category-selection"
          module={SkillSelectionComponent}
          skill_panel={@this_skill_panel}
          skill_class={@this_skill_class}
          skill_unit={@skill_unit}
          skill_category={@skill_category}
          target={Bright.DraftSkillUnits.DraftSkillCategory}
          on_select={on_select_skill_category(@id)}
        />

        <:actions>
          <.button phx-disable-with="Saving...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{form_skill_category: skill_category}, socket) do
    # ParentSelectionComponentの選択結果受け取り
    {:ok, assign(socket, :skill_category, skill_category)}
  end

  def update(%{skill: skill} = assigns, socket) do
    changeset = DraftSkillUnits.change_draft_skill(skill)
    skill_category = DraftSkillUnits.get_draft_skill_category!(skill.draft_skill_category_id)
    skill_unit = DraftSkillUnits.get_draft_skill_unit!(skill_category.draft_skill_unit_id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:skill_unit, skill_unit)
     |> assign(:skill_category, skill_category)
     |> assign_form(changeset)}
  end

  def handle_event("select", %{"id" => id}, socket) do
    skill_category = DraftSkillUnits.get_draft_skill_category!(id)

    {:noreply, assign(socket, :skill_category, skill_category)}
  end

  def handle_event("save", %{"draft_skill" => skill_params}, socket) do
    skill = socket.assigns.skill

    skill_category =
      DraftSkillUnits.get_draft_skill_category!(skill_params["draft_skill_category_id"])

    # 末尾追加とする
    position =
      DraftSkillUnits.get_max_position(skill_category, :draft_skills)
      |> Kernel.+(1)

    skill_params = Map.put(skill_params, "position", position)

    case DraftSkillUnits.update_draft_skill(skill, skill_params) do
      {:ok, _skill} ->
        {:noreply,
         socket
         |> put_flash(:info, "スキルを移動しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp on_select_skill_category(id) do
    fn skill_category ->
      send_update(__MODULE__, id: id, form_skill_category: skill_category)
    end
  end
end
