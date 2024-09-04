defmodule BrightWeb.SkillListComponent do
  @moduledoc """
  Skill List Component
  """
  use BrightWeb, :live_component
  alias Bright.SkillPanels
  alias BrightWeb.PathHelper
  import BrightWeb.TabComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-80 text-xs">
      <ul :if={Enum.count(@skill_panels) == 0} class="flex gap-y-2.5 flex-col">
        <li class="flex">
          <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
            データはありません
          </div>
        </li>
      </ul>
      <div class="min-h-[170px]">
        <div :if={Enum.count(@skill_panels) > 0} class="flex">
          <div class="w-8"></div>
          <div class="w-48 font-bold text-right pr-1">クラス</div>
          <div class="w-8 font-bold pl-2">1</div>
          <div class="w-8 font-bold pl-2">2</div>
          <div class="w-8 font-bold pl-2">3</div>
        </div>
        <%= for skill_panel <- @skill_panels do %>
          <.skill_panel
            skill_panel={skill_panel}
            display_user={@display_user}
            me={@me}
            anonymous={@anonymous}
            root={@root}
            current_skill_class={@current_skill_class}
          />
        <% end %>
      </div>
      <.tab_footer
        id={@id}
        page={@page}
        total_pages={@total_pages}
        target={@myself}
      />
    </div>
    """
  end

  defp skill_panel(assigns) do
    skill_classes = assigns.skill_panel.skill_classes
    is_star = assigns.skill_panel.user_skill_panels.is_star

    assigns =
      assigns
      |> assign(:skill_classes, skill_classes)
      |> assign(:is_star, is_star)

    ~H"""
    <div class="flex flex-wrap lg:flex-nowrap">
      <div class="w-8 font-bold">
        <span :if={@me} class={"material-icons text-#{get_star_style(@is_star)}"}>
          star
        </span>
      </div>
      <div class="text-left font-bold w-48 truncate mt-1" >
        <%= @skill_panel.name %>
      </div>
      <%= for skill_class <- @skill_classes do %>
        <.skill_gem
          score={List.first(skill_class.skill_class_scores)}
          skill_class={skill_class}
          skill_panel={@skill_panel}
          display_user={@display_user}
          me={@me}
          anonymous={@anonymous}
          root={@root}
          current_skill_class={@current_skill_class}
        />
      <% end %>
    </div>
    """
  end

  defp skill_gem(%{score: nil} = assigns) do
    ~H"""
    <div class="w-8" />
    """
  end

  defp skill_gem(%{score: %{level: level}} = assigns) do
    assigns =
      assigns
      |> assign(:icon_path, icon_path(level))
      |> assign(:level, level)

    ~H"""
    <div class="w-8">
      <.link href={PathHelper.skill_panel_path(@root, @skill_panel, @display_user, @me, @anonymous) <> "?class=#{@skill_class.class}"}>
        <p class={"border hover:cursor-pointer inline-flex items-end pl-1 #{if selected?(@skill_class, @current_skill_class), do: "border-[003D36] bg-[#004D36]", else: "border-[#12B7A3] hover:border-[#004D36] hover:bg-[#EDFFF8]" }"}>
          <img src={@icon_path} class="mr-1" />
        </p>
      </.link>
    </div>
    """
  end

  defp selected?(_, nil), do: false

  defp selected?(skill_class, current_skill_class) do
    skill_class.id == current_skill_class.id
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, current_skill_class: nil, per_page: 5)}
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign_paginate(assigns.display_user, Map.get(assigns, :career_field))
    |> then(&{:ok, &1})
  end

  def assign_paginate(socket, user, career_field, page \\ 1) do
    %{page_number: page, total_pages: total_pages, entries: skill_panels} =
      list_skill_panels(user, career_field, page, socket.assigns.per_page)

    socket
    |> assign(:skill_panels, skill_panels)
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
  end

  @impl true
  def handle_event("previous_button_click", _params, socket) do
    %{
      display_user: user,
      career_field: career_field,
      page: page
    } = socket.assigns

    page = if page - 1 < 1, do: 1, else: page - 1

    socket
    |> assign_paginate(user, career_field, page)
    |> then(&{:noreply, &1})
  end

  def handle_event("next_button_click", _params, socket) do
    %{
      display_user: user,
      career_field: career_field,
      page: page,
      total_pages: total_pages
    } = socket.assigns

    page = if page + 1 > total_pages, do: total_pages, else: page + 1

    socket
    |> assign_paginate(user, career_field, page)
    |> then(&{:noreply, &1})
  end

  defp list_skill_panels(user, nil, page, per_page) do
    SkillPanels.list_users_skill_panels_all_career_field([user.id], page, per_page)
  end

  defp list_skill_panels(user, career_field, page, _per_page) do
    # アクセス方法の統一のためis_startを`user_skill_panels.is_star`で引けるようにしている
    user_skill_panels =
      Bright.Repo.preload(user, [:user_skill_panels]).user_skill_panels
      |> Map.new(&{&1.skill_panel_id, &1})

    SkillPanels.list_users_skill_panels_by_career_field([user.id], career_field.name_en, page)
    |> Map.update!(:entries, fn skill_panels ->
      Enum.map(skill_panels, &Map.put(&1, :user_skill_panels, Map.get(user_skill_panels, &1.id)))
    end)
  end

  defp icon_base_path(file), do: "/images/common/icons/#{file}"
  defp icon_path(:beginner), do: icon_base_path("jemLow.svg")
  defp icon_path(:normal), do: icon_base_path("jemMiddle.svg")
  defp icon_path(:skilled), do: icon_base_path("jemHigh.svg")

  defp get_star_style(true), do: "brightGreen-300"
  defp get_star_style(false), do: "brightGray-100"
end
