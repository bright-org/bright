defmodule BrightWeb.Admin.DraftSkillClassLive.SkillUnitAddFormComponent do
  use BrightWeb, :live_component

  alias Bright.DraftSkillUnits
  alias Bright.DraftSkillPanels

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
        phx-change="select"
      >
        <input type="hidden" name="skill_unit_id" value={@skill_unit && @skill_unit.id} />

        <%= if @skill_panel_options do %>
          <select
            name="skill_panel_id"
            class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
          >
            <option value="">-- スキルパネル選択 --</option>
            <%= Phoenix.HTML.Form.options_for_select(@skill_panel_options, @skill_panel && @skill_panel.id) %>
          </select>
        <% end %>

        <%= if @skill_panel && @skill_class_options do %>
          <select
            name="skill_class_id"
            class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
          >
            <option value="">-- スキルクラス選択 --</option>
            <%= Phoenix.HTML.Form.options_for_select(@skill_class_options, @skill_class && @skill_class.id) %>
          </select>
        <% end %>

        <%= if @skill_class && @skill_unit_options do %>
          <select
            name="skill_unit_id"
            class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
          >
            <option value="">-- スキルユニット選択 --</option>
            <%= Phoenix.HTML.Form.options_for_select(@skill_unit_options, @skill_unit && @skill_unit.id) %>
          </select>
        <% end %>

        <.button class="mt-4" phx-disable-with="Saving..." disabled={is_nil(@skill_unit)}>保存</.button>
      </form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> reset_selection()
     |> assign_skill_panel_options()}
  end

  @impl true
  def handle_event("save", %{"skill_unit_id" => _} = _params, socket) do
    %{
      this_skill_class: skill_class,
      skill_unit: skill_unit
    } = socket.assigns

    DraftSkillUnits.create_draft_skill_class_unit(skill_class, skill_unit)

    {:noreply,
     socket
     |> put_flash(:info, "知識エリアを追加しました")
     |> push_patch(to: socket.assigns.patch)}
  end

  def handle_event("select", %{"_target" => ["skill_panel_id"]} = params, socket) do
    %{"skill_panel_id" => skill_panel_id} = params
    skill_panel = DraftSkillPanels.get_skill_panel!(skill_panel_id)

    {:noreply,
     socket
     |> assign(:skill_panel, skill_panel)
     |> assign_skill_class_options()}
  end

  def handle_event("select", %{"_target" => ["skill_class_id"]} = params, socket) do
    %{"skill_class_id" => skill_class_id} = params
    skill_class = DraftSkillPanels.get_draft_skill_class!(skill_class_id)

    {:noreply,
     socket
     |> assign(:skill_class, skill_class)
     |> assign_skill_unit_options()}
  end

  def handle_event("select", %{"_target" => ["skill_unit_id"]} = params, socket) do
    %{"skill_unit_id" => skill_unit_id} = params
    skill_unit = DraftSkillUnits.get_draft_skill_unit!(skill_unit_id)

    {:noreply,
     socket
     |> assign(:skill_unit, skill_unit)}
  end

  defp reset_selection(socket) do
    socket
    |> assign(
      skill_panel: nil,
      skill_class: nil,
      skill_unit: nil
    )
  end

  defp assign_skill_panel_options(socket) do
    options =
      DraftSkillPanels.list_skill_panels()
      |> Enum.sort_by(& &1.updated_at, {:desc, NaiveDateTime})
      |> Enum.map(&{&1.name, &1.id})

    assign(socket, :skill_panel_options, options)
  end

  defp assign_skill_class_options(socket) do
    %{skill_panel: skill_panel, this_skill_class: this_skill_class} = socket.assigns

    options =
      Ecto.assoc(skill_panel, :draft_skill_classes)
      |> DraftSkillPanels.list_draft_skill_classes()
      |> Enum.reject(&(&1.id == this_skill_class.id))
      |> Enum.sort_by(& &1.class, :asc)
      |> Enum.map(&{&1.name, &1.id})

    assign(socket, :skill_class_options, options)
  end

  defp assign_skill_unit_options(socket) do
    %{skill_class: skill_class} = socket.assigns

    options =
      DraftSkillUnits.list_draft_skill_units_on_class(skill_class)
      |> Enum.map(&{&1.name, &1.id})

    assign(socket, :skill_unit_options, options)
  end
end
