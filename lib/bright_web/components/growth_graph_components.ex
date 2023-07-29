defmodule BrightWeb.GrowthGraphComponents do
  @moduledoc """
  Growth Graph Components
  """

  use Phoenix.Component

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
end
