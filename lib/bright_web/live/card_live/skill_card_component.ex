# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.SkillCardComponent do
  @moduledoc """
  Skill Card Component
  """
  use BrightWeb, :live_component
  import BrightWeb.TabComponents
  alias Bright.SkillScores

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
        <div class="py-4 px-7 flex gap-y-2 flex-col">
          <div class="bg-brightGray-10 rounded-md text-base flex px-5 py-4 content-between">
            <table class="table-fixed skill-table -mt-2">
              <thead>
                <tr>
                  <th></th>
                  <th class="pl-8">クラス1</th>
                  <th class="pl-8">クラス2</th>
                  <th class="pl-8">クラス3</th>
                </tr>
              </thead>
              <tbody>
                <%= for skill_panel <- @skill_panels do %>
                  <.skill_panel skill_panel={skill_panel} />
                <% end %>
              </tbody>
            </table>
          </div>
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
     |> assign(:skill_panels, SkillScores.get_level_by_class_in_skills_panel())}
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
    <tr>
      <td><%= @skill_panel.name %></td>
      <%= for level <- @skill_panel.levels do %>
        <.skill_gem level={level}/>
      <% end %>
    </tr>
    """
  end

  defp skill_gem(%{level: nil} = assigns) do
    ~H"""
    <td>
    </td>
    """
  end

  defp skill_gem(assigns) do
    assigns =
      assigns
      |> assign(:icon_path, icon_path(assigns.level))

    ~H"""
    <td>
      <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
        <img src={@icon_path} class="mr-1" /><%= level_text(@level) %>
      </p>
    </td>
    """
  end

  defp icon_base_path(file), do: "/images/common/icons/#{file}"
  defp icon_path("beginner"), do: icon_base_path("jemLow.svg")
  defp icon_path("normal"), do: icon_base_path("jemMiddle.svg")
  defp icon_path("skilled"), do: icon_base_path("jemHigh.svg")

  defp level_text("beginner"), do: "見習い"
  defp level_text("normal"), do: "平均"
  defp level_text("skilled"), do: "ベテラン"
end
