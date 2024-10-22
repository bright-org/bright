defmodule BrightWeb.ChartComponents do
  @moduledoc """
  Chart Components
  """
  use Phoenix.Component

  @doc """
  Renders a Skill Gem

  ## Examples
      <.skill_gem data="[90, 80, 75, 60]" id="gem-single-skill4" labels={["Elixir本体", "ライブラリ", "環境構築", "関連スキル"]} size="sm" />
      <.skill_gem data={[[50, 50, 50, 80, 80, 80], [80, 80, 80, 50, 50, 50]]} id="gem-single-skill6-2-3" labels={["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]} />
  """
  attr :id, :string, required: true
  attr :data, :list, required: true
  attr :labels, :list, required: true
  attr :links, :list, default: nil
  attr :size, :string, default: "default", values: ["sm", "md", "base", "sp", "default"]
  attr :display_link, :string, default: "true", values: ["true", "false"]
  attr :color_theme, :string, default: "other", values: ["myself", "other"]

  def skill_gem(assigns) do
    assigns =
      assigns
      |> assign(:labels, assigns.labels |> Jason.encode!())
      |> assign(:data, assigns.data |> Jason.encode!())
      |> assign(:links, assigns.links |> Jason.encode!())
      |> assign(:size_css, assigns.size |> get_gem_size_css())

    ~H"""
    <div
      id={@id}
      style={@size_css}
      phx-hook="SkillGem"
      phx-update="ignore"
      data-data={@data}
      data-labels={@labels}
      data-links={@links}
      data-size={@size}
      data-display-link={@display_link}
      data-color-theme={@color_theme}
    >
      <canvas class="w-full"></canvas>
    </div>
    """
  end

  @doc """
  Renders a Growth Graph

  ## DataSample

      %{
          myself: [nil, 0, 35, 45, 50, 70],
          other: [10, 10, 10, 10, 45, 80],
          role: [20, 20, 50, 60, 75, 100],
          now: 55,
          otherNow: 60,
          futureDisplay: true,
          labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2021.12"],
          otherLabels: ["2020.09", "2020.12", "2021.3", "2021.6", "2021.9"]
          myselfSelected: "2021.9",
          otherSelected: "2020.12",
          comparedOther: true
        }

  ## Examples

      <.growth_graph_demo data={see DataSample} id="growth-graph" />

  """
  attr :id, :string, required: true
  attr :data, :map, required: true
  attr :size, :string, default: "default"

  def growth_graph(assigns) do
    ~H"""
    <div
      id={@id}
      class="w-full"
      phx-hook="GrowthGraph"
      phx-update="ignore"
      data-data={complement_growth_graph_data(@data)}
      data-size={@size}
    >
      <canvas class="w-full"></canvas>
    </div>
    """
  end

  @doc """
  Renders a Doughnut Graph

  ## Examples

      <.doughnut_graph data="[90, 80, 75, 60]" id="doughnut" />

  """
  attr :id, :string, required: true
  attr :data, :list, required: true

  def doughnut_graph(assigns) do
    assigns =
      assigns
      |> assign(:data, assigns.data |> Jason.encode!())

    ~H"""
    <div
      id={@id}
      phx-hook="DoughnutGraph"
      phx-update="ignore"
      data-data={@data}
    >
      <canvas></canvas>
    </div>
    """
  end

  defp complement_growth_graph_data(data) do
    # 成長グラフデータ調整
    # - 「現在」までの変遷を入れる場合は表示点を１つ減らす
    maybe_cut_down_past_one(data)
    |> Jason.encode!()
  end

  defp maybe_cut_down_past_one(%{displayProgress: true} = data) do
    data
    |> Map.update!(:myself, &List.delete_at(&1, 0))
    |> Map.update!(:labels, &List.delete_at(&1, 0))
  end

  defp maybe_cut_down_past_one(data), do: data

  defp get_gem_size_css("sm"), do: "width: 250px; height: 165px;"
  defp get_gem_size_css("sp"), do: "width: 340px; height: 300px;"
  defp get_gem_size_css("md"), do: "width: 535px; height: 450px;"
  defp get_gem_size_css(_), do: "width: 450px; height: 450px;"
end
