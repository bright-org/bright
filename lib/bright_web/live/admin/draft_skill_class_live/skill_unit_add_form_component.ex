defmodule BrightWeb.Admin.DraftSkillClassLive.SkillUnitAddFormComponent do
  use BrightWeb, :live_component

  alias Bright.DraftSkillUnits
  alias BrightWeb.Admin.DraftSkillClassLive.SkillSelectionComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header class="my-2">
        <p>知識エリアを共通利用する</p>
      </.header>

      <form
        id="skill-unit-add-form"
        phx-target={@myself}
        phx-submit="save"
      >
        <input type="hidden" name="skill_unit_id" value={@skill_unit && @skill_unit.id} />

        <.live_component
          id="skill-unit-selection"
          module={SkillSelectionComponent}
          skill_panel={@this_skill_panel}
          target={Bright.DraftSkillUnits.DraftSkillUnit}
          on_select={on_select_skill_unit(@id)}
        />

        <.button class="mt-4" phx-disable-with="Saving..." disabled={is_nil(@skill_unit)}>保存</.button>
      </form>
    </div>
    """
  end

  @impl true
  def update(%{form_skill_unit: skill_unit}, socket) do
    # ParentSelectionComponentの選択結果受け取り
    {:ok, assign(socket, :skill_unit, skill_unit)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:skill_unit, nil)}
  end

  @impl true
  def handle_event("save", %{"skill_unit_id" => _} = _params, socket) do
    %{
      this_skill_class: skill_class,
      skill_unit: skill_unit
    } = socket.assigns

    DraftSkillUnits.create_draft_skill_class_unit(skill_class, skill_unit)
    |> case do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "知識エリアを追加しました")
         |> push_patch(to: socket.assigns.patch)}

      _ ->
        # HACKME 重複などで追加できないケースがある。必要に応じて対応
        {:noreply, socket}
    end
  end

  defp on_select_skill_unit(id) do
    fn skill_unit ->
      send_update(__MODULE__, id: id, form_skill_unit: skill_unit)
    end
  end
end
