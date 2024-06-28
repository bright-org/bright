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
    <div class="flex flex-col w-80">
      <ul :if={Enum.count(@skill_panels) == 0} class="flex gap-y-2.5 flex-col">
        <li class="flex">
          <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
            データはありません
          </div>
        </li>
      </ul>
      <div class="min-h-[170px]">
        <div :if={Enum.count(@skill_panels) > 0} class="flex">
          <div class="w-8 font-bold"></div>
          <div class="w-44 font-bold text-right pr-1">クラス</div>
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
      <div class="text-left font-bold w-44 truncate mb-2" >
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
        />
      <% end %>
    </div>
    """
  end

  defp skill_gem(%{score: nil} = assigns) do
    ~H"""
    <div class="w-28 lg:w-36"></div>
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
        <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end pl-1">
          <img src={@icon_path} class="mr-1" />
        </p>
      </.link>
    </div>
    """
  end

  @impl true
  def update(%{display_user: user} = assigns, socket) do
    socket
    |> assign(assigns)
    |> assign_paginate(user.id)
    |> then(&{:ok, &1})
  end

  def assign_paginate(socket, user_id, page \\ 1) do
    %{page_number: page, total_pages: total_pages, entries: skill_panels} =
      SkillPanels.list_users_skill_panels_all_career_field([user_id], page)

    socket
    |> assign(:skill_panels, skill_panels)
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
  end

  @impl true
  def handle_event("previous_button_click", _params, %{assigns: %{display_user: user}} = socket) do
    %{page: page} = socket.assigns
    page = if page - 1 < 1, do: 1, else: page - 1

    socket
    |> assign_paginate(user.id, page)
    |> then(&{:noreply, &1})
  end

  def handle_event("next_button_click", _params, %{assigns: %{display_user: user}} = socket) do
    %{page: page, total_pages: total_pages} = socket.assigns
    page = if page + 1 > total_pages, do: total_pages, else: page + 1

    socket
    |> assign_paginate(user.id, page)
    |> then(&{:noreply, &1})
  end

  defp icon_base_path(file), do: "/images/common/icons/#{file}"
  defp icon_path(:beginner), do: icon_base_path("jemLow.svg")
  defp icon_path(:normal), do: icon_base_path("jemMiddle.svg")
  defp icon_path(:skilled), do: icon_base_path("jemHigh.svg")

  defp get_star_style(true), do: "brightGreen-300"
  defp get_star_style(false), do: "brightGray-100"
end
