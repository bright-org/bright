defmodule BrightWeb.Admin.SkillClassLive.SkillReplaceFormComponent do
  use BrightWeb, :live_component

  alias Bright.SkillUnits
  alias BrightWeb.Admin.SkillClassLive.SkillSelectionComponent

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
        <.input field={@form[:skill_category_id]} value={@skill_category && @skill_category.id} type="hidden" />

        <.live_component
          id="skill-category-selection"
          module={SkillSelectionComponent}
          skill_panel={@this_skill_panel}
          skill_class={@this_skill_class}
          skill_unit={@this_skill_unit}
          skill_category={@this_skill_category}
          target={Bright.SkillUnits.SkillCategory}
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
    changeset = SkillUnits.change_skill(skill)
    skill_category = SkillUnits.get_skill_category!(skill.skill_category_id)
    skill_unit = SkillUnits.get_skill_unit!(skill_category.skill_unit_id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:this_skill_unit, skill_unit)
     |> assign(:this_skill_category, skill_category)
     |> assign(:skill_category, skill_category)
     |> assign_form(changeset)}
  end

  def handle_event("select", %{"id" => id}, socket) do
    skill_category = SkillUnits.get_skill_category!(id)

    {:noreply, assign(socket, :skill_category, skill_category)}
  end

  def handle_event("save", %{"skill" => skill_params}, socket) do
    skill = socket.assigns.skill

    skill_category =
      SkillUnits.get_skill_category!(skill_params["skill_category_id"])

    # 末尾追加とする
    position =
      SkillUnits.get_max_position(skill_category, :skills)
      |> Kernel.+(1)

    skill_params = Map.put(skill_params, "position", position)

    case SkillUnits.update_skill(skill, skill_params) do
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
