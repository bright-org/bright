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
  attr :size, :string, default: "base", values: ["sm", "base"]
  attr :display_link, :string, default: "true", values: ["true", "false"]
  attr :color_theme, :string, default: "other", values: ["myself", "other"]

  def skill_gem(assigns) do
    assigns =
      assigns
      |> assign(:labels, assigns.labels |> Jason.encode!())
      |> assign(:data, assigns.data |> Jason.encode!())

    ~H"""
    <div
      id={@id}
      phx-hook="SkillGem"
      phx-update="ignore"
      data-data={@data}
      data-labels={@labels}
      data-links={@links}
      data-size={@size}
      data-display-link={@display_link}
      data-color-theme={@color_theme}
    >
      <canvas></canvas>
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
          futureEnabled: true,
          labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
          myselfSelected: "2021.9",
          otherSelected: "2020.12"
        }

  ## Examples

      <.growth_graph data={%{labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"], role: [10, 20, 50, 60, 75, 90], myself: [nil, 0, 35, 45, 55, 60]}} id="growth-graph-single-sample2"/>

  """
  attr :id, :string, required: true
  attr :data, :map, required: true

  def growth_graph(assigns) do
    assigns =
      assigns
      |> assign(:data, assigns.data |> Jason.encode!())

    ~H"""
    <div
      id={@id}
      phx-hook="GrowthGraph"
      phx-update="ignore"
      data-data={@data}
    >
      <canvas></canvas>
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
end
