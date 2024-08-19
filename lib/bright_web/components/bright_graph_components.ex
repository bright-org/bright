defmodule BrightWeb.BrightGraphComponents do
  @moduledoc """
  Graph
  """
  use Phoenix.Component

  @doc """
  Renders a TriangleGraph

  ## Examples

      <.triangle_graph data={%{normal: 35, beginner: 35, skilled: 30}} id="triangle-graph-single-default"/>

  """
  attr :id, :string, required: true
  attr :data, :map, required: true

  def triangle_graph(assigns) do
    assigns =
      assigns
      |> assign(:data, assigns.data |> Jason.encode!())

    ~H"""
    <div
      id={@id}
      phx-hook="TriangleGraph"
      phx-update="ignore"
      data-data={@data}
    >
      <canvas width="350" height="130"></canvas>
    </div>
    """
  end
end
