defmodule BrightWeb.ChartLive.GrowthGraphComponent do
  @moduledoc """
  Growth Graph Component
  """
  use BrightWeb, :live_component
  import BrightWeb.ChartComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.growth_graph data={@data} id="growth-graph-single-sample2"/>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:data, %{
        labels: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
        role: [10, 20, 50, 60, 75, 100],
        myself: [nil, 0, 35, 45, 55, 65],
        other: [10, 10, 25, 35, 45, 70],
        now: 65,
        myselfSelected: "2023.6",
        otherSelected: "2022.12"
      })

    {:ok, socket}
  end
end
