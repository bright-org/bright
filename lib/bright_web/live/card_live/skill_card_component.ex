# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.SkillCardComponent do
  @moduledoc """
  Skill Card Component
  """
  use BrightWeb, :live_component
  import BrightWeb.TabComponents

  @tabs ["エンジニア", "インフラ", "デザイナー", "マーケッター"]

  # TODO selected_tab,selected_tab,page,total_pagesは未実装でダミーです
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.tab
        id="skill_card"
        selected_tab="エンジニア"
        page={1}
        total_pages={1}
        target={@myself}
        tabs={@tabs}
      >
        <div class="py-4 px-7 flex gap-y-2 flex-col">
          <%= for skill <- assigns.skills do %>
            <.skill_genre skills={skill} />
          <% end %>
        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:tabs, @tabs)
     # TODO　サンプルデータはDBの処理を作成後消すこと
     |> assign(:skills, sample())}
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => "skill_card"},
        socket
      ) do
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

  defp skill_genre(assigns) do
    ~H"""
    <div class="bg-brightGray-10 rounded-md text-base flex px-5 py-4 content-between">
      <p class="font-bold w-[150px] text-left text-sm">
        <%= assigns.skills.genre_name %>
      </p>
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
          <%= for skill_panel <- assigns.skills.skill_panels do %>
            <.skill_panel skill_panel={skill_panel} />
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  defp skill_panel(assigns) do
    ~H"""
    <tr>
      <td><%= assigns.skill_panel.name %></td>
      <%= for level <- assigns.skill_panel.levels do %>
        <.skill_gem level={level}/>
      <% end %>
    </tr>
    """
  end

  defp skill_gem(%{level: :none} = assigns) do
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
        <img src={@icon_path} class="mr-1" /><%= level_text(assigns.level) %>
      </p>
    </td>
    """
  end

  defp icon_base_path(file), do: "/images/common/icons/#{file}"
  defp icon_path(:beginner), do: icon_base_path("jemLow.svg")
  defp icon_path(:normal), do: icon_base_path("jemMiddle.svg")
  defp icon_path(:skilled), do: icon_base_path("jemHigh.svg")

  defp level_text(:beginner), do: "見習い"
  defp level_text(:normal), do: "平均"
  defp level_text(:skilled), do: "ベテラン"

  # TODO　サンプルデータはDBの処理を作成後消すこと
  defp sample() do
    [
      %{
        genre_name: "Webアプリ開発",
        skill_panels: [%{name: "Elixir", levels: [:skilled, :normal, :beginner]}]
      },
      %{
        genre_name: "AI開発これはDBから読み込んでません",
        skill_panels: [
          %{name: "Elixir", levels: [:skilled, :normal, :none]},
          %{name: "Python", levels: [:skilled, :none, :none]}
        ]
      },
      %{
        genre_name: "PM サンプルです",
        skill_panels: [
          %{name: "", levels: [:skilled, :normal, :none]}
        ]
      }
    ]
  end
end
