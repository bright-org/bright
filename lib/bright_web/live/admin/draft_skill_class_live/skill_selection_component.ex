defmodule BrightWeb.Admin.DraftSkillClassLive.SkillSelectionComponent do
  @moduledoc """
  スキル階層

  スキルパネル - スキルクラス - スキルユニット - スキルカテゴリー

  を決めるためのselectで使用するコンポーネント

  どこまでの階層が必要か(target)、
  その階層まで決まった際の挙動(on_select)
  は本コンポーネントを呼び出す方から渡すこと

  ## Example

        <.live_component
          id="skill-unit-selection"
          module={SkillSelectionComponent}
          skill_panel={@this_skill_panel}
          target={Bright.DraftSkillUnits.DraftSkillUnit}
          on_select={on_select_skill_unit(@id)}
        />
  """

  use BrightWeb, :live_component

  alias Bright.DraftSkillUnits
  alias Bright.DraftSkillPanels

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <%= if @skill_panel_options do %>
        <select
          name="skill_panel_id"
          class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
          phx-change="select_skill_panel"
          phx-target={@myself}
        >
          <option value="">-- スキルパネル選択 --</option>
          <%= Phoenix.HTML.Form.options_for_select(@skill_panel_options, @skill_panel && @skill_panel.id) %>
        </select>
      <% end %>

      <%= if @skill_panel && @skill_class_options do %>
        <select
          name="skill_class_id"
          class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
          phx-change="select_skill_class"
          phx-target={@myself}
        >
          <option value="">-- スキルクラス選択 --</option>
          <%= Phoenix.HTML.Form.options_for_select(@skill_class_options, @skill_class && @skill_class.id) %>
        </select>
      <% end %>

      <%= if @skill_class && @skill_unit_options do %>
        <select
          name="skill_unit_id"
          class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
          phx-change="select_skill_unit"
          phx-target={@myself}
        >
          <option value="">-- スキルユニット選択 --</option>
          <%= Phoenix.HTML.Form.options_for_select(@skill_unit_options, @skill_unit && @skill_unit.id) %>
        </select>
      <% end %>

      <%= if @skill_unit && @skill_category_options do %>
        <select
          name="skill_category_id"
          class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
          phx-change="select_skill_category"
          phx-target={@myself}
        >
          <option value="">-- スキルカテゴリ選択 --</option>
          <%= Phoenix.HTML.Form.options_for_select(@skill_category_options, @skill_category && @skill_category.id) %>
        </select>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> init_selection()}
  end

  @impl true
  def handle_event("select_skill_panel", params, socket) do
    %{"skill_panel_id" => skill_panel_id} = params
    skill_panel = DraftSkillPanels.get_skill_panel(skill_panel_id)

    {:noreply,
     socket
     |> assign(:skill_panel, skill_panel)
     |> assign(:skill_class, nil)
     |> assign(:skill_unit, nil)
     |> assign(:skill_category, nil)
     |> assign_skill_class_options()
     |> assign_skill_unit_options()
     |> assign_skill_category_options()}
  end

  def handle_event("select_skill_class", params, socket) do
    %{"skill_class_id" => skill_class_id} = params
    skill_class = DraftSkillPanels.get_draft_skill_class!(skill_class_id)

    {:noreply,
     socket
     |> assign(:skill_class, skill_class)
     |> assign(:skill_unit, nil)
     |> assign(:skill_category, nil)
     |> assign_skill_unit_options()
     |> assign_skill_category_options()}
  end

  def handle_event("select_skill_unit", params, socket) do
    %{"skill_unit_id" => skill_unit_id} = params
    %{target: target, on_select: on_select} = socket.assigns

    skill_unit = DraftSkillUnits.get_draft_skill_unit(skill_unit_id)

    if is_struct(skill_unit, target) do
      on_select.(skill_unit)

      {:noreply,
       socket
       |> assign(:skill_unit, skill_unit)}
    else
      {:noreply,
       socket
       |> assign(:skill_unit, skill_unit)
       |> assign(:skill_category, nil)
       |> assign_skill_category_options()}
    end
  end

  def handle_event("select_skill_category", params, socket) do
    %{"skill_category_id" => skill_category_id} = params
    %{target: target, on_select: on_select} = socket.assigns

    skill_category = DraftSkillUnits.get_draft_skill_category(skill_category_id)

    if is_struct(skill_category, target) do
      on_select.(skill_category)

      {:noreply,
       socket
       |> assign(:skill_category, skill_category)}
    else
      # 現状スキルを選ぶことはない用途はないのでここまで
      {:noreply, socket}
    end
  end

  defp assign_skill_panel_options(socket) do
    options =
      DraftSkillPanels.list_skill_panels()
      |> Enum.sort_by(& &1.updated_at, {:desc, NaiveDateTime})
      |> Enum.map(&{&1.name, &1.id})

    assign(socket, :skill_panel_options, options)
  end

  defp assign_skill_class_options(%{assigns: %{skill_panel: nil}} = socket) do
    assign(socket, :skill_class_options, nil)
  end

  defp assign_skill_class_options(socket) do
    %{skill_panel: skill_panel} = socket.assigns

    options =
      Ecto.assoc(skill_panel, :draft_skill_classes)
      |> DraftSkillPanels.list_draft_skill_classes()
      |> Enum.sort_by(& &1.class, :asc)
      |> Enum.map(&{&1.name, &1.id})

    assign(socket, :skill_class_options, options)
  end

  defp assign_skill_unit_options(%{assigns: %{skill_class: nil}} = socket) do
    assign(socket, :skill_unit_options, nil)
  end

  defp assign_skill_unit_options(socket) do
    %{skill_class: skill_class} = socket.assigns

    options =
      DraftSkillUnits.list_draft_skill_units_on_class(skill_class)
      |> Enum.map(&{&1.name, &1.id})

    assign(socket, :skill_unit_options, options)
  end

  defp assign_skill_category_options(%{assigns: %{skill_unit: nil}} = socket) do
    assign(socket, :skill_category_options, nil)
  end

  defp assign_skill_category_options(socket) do
    %{skill_unit: skill_unit} = socket.assigns

    options =
      DraftSkillUnits.list_draft_skill_categorys_on_unit(skill_unit)
      |> Enum.map(&{&1.name, &1.id})

    assign(socket, :skill_category_options, options)
  end

  defp init_selection(socket) do
    socket
    |> assign_new(:skill_panel, fn -> nil end)
    |> assign_new(:skill_class, fn -> nil end)
    |> assign_new(:skill_unit, fn -> nil end)
    |> assign_new(:skill_category, fn -> nil end)
    |> assign_skill_panel_options()
    |> assign_skill_class_options()
    |> assign_skill_unit_options()
    |> assign_skill_category_options()
  end
end
