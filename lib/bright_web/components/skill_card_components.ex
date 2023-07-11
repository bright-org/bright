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
  def skill_card(assigns) do
    ~H"""
    <div>
      <h5>保有スキル（ジェムをクリックすると成長グラフが見れます）</h5>
      <.tab tabs={["エンジニア", "インフラ", "デザイナー", "マーケッター"]}>
        <.skill_card_body />
      </.tab>
    </div>
    """
  end

  def skill_card_body(assigns) do
    ~H"""
    <div class="py-4 px-7 flex gap-y-3 flex-col">
      <%= for _i <- 1..3 do %>
        <.skill_card_genre />
      <% end %>
    </div>
    """
  end

  def skill_card_genre(assigns) do
    ~H"""
    <div class="bg-brightGray-10 rounded-md text-base flex p-5 content-between">
      <p class="font-bold w-36 text-left text-sm">
        Webアプリ開発
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
          <%= for _j <- 1..3 do %>
            <tr>
              <td>Elixir</td>
              <.skill_card_genre_cell />
              <.skill_card_genre_cell />
              <.skill_card_genre_cell />
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  attr :level, :atom, default: :skilled

  def skill_card_genre_cell(assigns) do
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
