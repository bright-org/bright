# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.SkillCardComponent do
  @moduledoc """
  Skill Card Component
  """
  use BrightWeb, :live_component
  import BrightWeb.TabComponents
  alias Bright.UserSkillPanels

  # TODO selected_tab,selected_tab,page,total_pagesは未実装でダミーです
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.tab
        id="skill_card"
        selected_tab={@selected_tab}
        page={1}
        total_pages={1}
        target={@myself}
        tabs={@tabs}
      >
        <div class="py-6 px-7 flex gap-y-4 flex-col min-h-[464px]">
          <ul :if={Enum.count(@skill_panels) == 0} class="flex gap-y-2.5 flex-col">
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
              <%= Enum.into(@tabs, %{}) |> Map.get(@selected_tab) %>はありません
              </div>
            </li>
          </ul>
          <div :if={Enum.count(@skill_panels) > 0} class="flex">
            <div class="flex-1 text-left font-bold"></div>
            <div class="w-36 font-bold">クラス1</div>
            <div class="w-36 font-bold">クラス2</div>
            <div class="w-36 font-bold">クラス3</div>
          </div>
          <%= for skill_panel <- @skill_panels do %>
            <.skill_panel skill_panel={skill_panel} />
          <% end %>
        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    tabs =
      Bright.Jobs.list_career_fields()
      |> Enum.map(&{&1.name_en, &1.name_ja})

    {:ok, assign(socket, :tabs, tabs)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:selected_tab, "engineer")
     |> assign(
       :skill_panels,
       UserSkillPanels.get_level_by_class_in_skills_panel(assigns.current_user.id)
     )}
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => "skill_card", "tab_name" => tab_name},
        socket
      ) do
    socket =
      socket
      |> assign(:selected_tab, tab_name)

    # TODO 処理は未実装
    {:noreply, socket}
  end

  def handle_event(
        "previous_button_click",
        %{"id" => "skill_card"},
        socket
      ) do
    # TODO 処理は未実装
    {:noreply, socket}
  end

  def handle_event(
        "next_button_click",
        %{"id" => "skill_card"},
        socket
      ) do
    # TODO 処理は未実装
    {:noreply, socket}
  end

  defp skill_panel(assigns) do
    ~H"""
    <div class="flex">
      <div class="flex-1 text-left font-bold">
        <.link
          href={~p"/panels/#{@skill_panel.id}/graph"}
          method="get"
        >
          <%= @skill_panel.name %>
        </.link>
      </div>
      <%= for {level, class} <- Enum.with_index(@skill_panel.levels, 1) do %>
        <.skill_gem level={level} class={class} id={@skill_panel.id}/>
      <% end %>
    </div>
    """
  end

  defp skill_gem(%{level: :none} = assigns) do
    ~H"""
    <div class="w-36"></div>
    """
  end

  defp skill_gem(assigns) do
    assigns =
      assigns
      |> assign(:icon_path, icon_path(assigns.level))

    ~H"""
    <div class="w-36">
      <.link
        href={~p"/panels/#{@id}/graph?class=#{@class}"}
        method="get"
      >
        <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
          <img src={@icon_path} class="mr-1" /><%= level_text(@level) %>
        </p>
      </.link>
    </div>
    """
  end

  defp icon_base_path(file), do: "/images/common/icons/#{file}"
  defp icon_path(:beginner), do: icon_base_path("jemLow.svg")
  defp icon_path(:normal), do: icon_base_path("jemMiddle.svg")
  defp icon_path(:skilled), do: icon_base_path("jemHigh.svg")

  defp level_text(:beginner), do: "見習い"
  defp level_text(:normal), do: "平均"
  defp level_text(:skilled), do: "ベテラン"
end
