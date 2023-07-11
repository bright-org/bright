defmodule BrightWeb.SkillCardComponents do
  @moduledoc """
  Skill Card Components
  """
  use Phoenix.Component
  import BrightWeb.TabComponents

  @doc """
  Renders a Skill Card

  ## Examples
      <.skill_card />
  """

  # TODO datasのデフォルトはマイページにロジックを書く時に消す
  attr :datas, :list,
    default: [
      %{
        name: "Webアプリ開発",
        panel_datas: [%{name: "Elixir", levels: [:skilled, :normal, :beginner]}]
      },
      %{
        name: "AI開発",
        panel_datas: [
          %{name: "Elixir", levels: [:skilled, :normal, :beginner]},
          %{name: "Python", levels: [:skilled, :normal, :beginner]}
        ]
      }
    ]

  def skill_card(assigns) do
    ~H"""
    <div>
      <h5>保有スキル（ジェムをクリックすると成長グラフが見れます）</h5>
      <.tab tabs={["エンジニア", "インフラ", "デザイナー", "マーケッター"]}>
        <.skill_card_body datas={@datas} />
      </.tab>
    </div>
    """
  end

  attr :datas, :list

  def skill_card_body(assigns) do
    ~H"""
    <div class="py-4 px-7 flex gap-y-3 flex-col">
      <%= for data <- assigns.datas do %>
        <.skill_card_genre genre_data={data} />
      <% end %>
    </div>
    """
  end

  attr :genre_data, :map

  def skill_card_genre(assigns) do
    ~H"""
    <div class="bg-brightGray-10 rounded-md text-base flex p-5 content-between">
      <p class="font-bold w-36 text-left text-sm">
        <%= assigns.genre_data.name %>
      </p>
      <table class="table-fixed skill-table">
        <thead>
          <tr>
            <th class="w-[110px]"></th>
            <th class="pl-8">クラス1</th>
            <th class="pl-8">クラス2</th>
            <th class="pl-8">クラス3</th>
          </tr>
        </thead>
        <tbody>
          <%= for panel_data <- assigns.genre_data.panel_datas do %>
            <.skill_card_genre_panel panel_data={panel_data} />
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  attr :panel_data, :map

  defp skill_card_genre_panel(assigns) do
    ~H"""
    <tr>
    <td><%= assigns.panel_data.name %></td>
    <%= for level <- assigns.panel_data.levels do %>
    <.skill_card_genre_cell level={level}/>
    <% end %>
    </tr>
    """
  end

  attr :level, :atom, default: :skilled

  defp skill_card_genre_cell(assigns) do
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
end
